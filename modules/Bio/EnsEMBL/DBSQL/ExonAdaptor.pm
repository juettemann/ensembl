# EnsEMBL Exon reading writing adaptor for mySQL
#
# Copyright EMBL-EBI 2001
#
# Author: Arne Stabenau
# based on 
# Elia Stupkas Gene_Obj
# 
# Date : 20.02.2001
#

=head1 NAME

Bio::EnsEMBL::DBSQL::ExonAdaptor - MySQL Database queries to generate and store exons (including supporting evidence)

=head1 SYNOPSIS

=head1 CONTACT

  Arne Stabenau: stabenau@ebi.ac.uk
  Elia Stupka  : elia@ebi.ac.uk
  Ewan Birney  : 

=head1 APPENDIX

=cut



package Bio::EnsEMBL::DBSQL::ExonAdaptor;

use vars qw( @ISA );
use strict;


use Bio::EnsEMBL::DBSQL::BaseAdaptor;
use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Exon;
use Bio::EnsEMBL::StickyExon;

@ISA = qw( Bio::EnsEMBL::DBSQL::BaseAdaptor );

=head2 fetch_by_dbID

 Title   : fetch_by_dbID
 Usage   : $exonAdaptor->fetch_by_dbID($exon_id)
 Function: 
 Example : $obj->remove_by_dbID(ENSE000034)
 Returns : nothing
 Args    : $exon_id

=cut


sub fetch_by_dbID {
  my $self = shift;
  my $dbID = shift;

  my $query = qq {
    SELECT  e.exon_id
      , e.contig_id
      , e.seq_start
      , e.seq_end
      , e.strand
      , e.phase
      , e.end_phase
      , e.sticky_rank
      , c.id cid
    FROM exon e,contig c
    WHERE e.exon_id = $dbID and c.internal_id = e.contig_id 
    ORDER BY e.sticky_rank DESC  };

  my $sth = $self->prepare($query);

  $sth->execute();


  my $hashRef;
  my $exon;

  if( $hashRef = $sth->fetchrow_hashref() ) {
    $exon = $self->_exon_from_sth( $sth, $hashRef );
  }

  delete $self->{rchash};
  return $exon;
}

=head2 fetch_by_stable_id

 Title   : fetch_by_stable_id
 Usage   : $exonAdaptor->fetch_by_stable_id( $exon_stable_id )
 Function: gets an exon by its stable_id
 Example : 
 Returns : exon Object or undef if none is found
 Args    : stable_id of an exon

=cut

sub fetch_by_stable_id {
  my $self = shift;
  my $stable_id = shift;

  my $sth = $self->prepare( "SELECT exon_id from exon_stable_id
                             WHERE stable_id = ?" );
  $sth->execute( $stable_id );
  if( my $arr = $sth->fetchrow_arrayref ) {
    my $exon = $self->fetch_by_dbID( $arr->[0] );
    return $exon;
  } else {
    $self->warn( "No Exon with this stable_id in the database!" );
    return undef;
  }
}


# returns list of exons or maybe empty list (gene not known)

sub fetch_by_geneId {
  my ( $self, $geneId ) = @_;
  my %exons;
  my $hashRef;
  my ( $currentId, $currentTranscript );

  if( !defined $geneId ) {
      $self->throw("Must has a geneId ... ");
  }

  my $query = qq {
    SELECT  e.exon_id
      , e.contig_id
      , e.seq_start
      , e.seq_end
      , e.strand
      , e.phase
      , e.end_phase
      , e.sticky_rank
      , c.id cid
    FROM exon e
      , exon_transcript et
      , transcript t
      , contig c
    WHERE t.gene_id = $geneId
      AND et.transcript_id = t.transcript_id
      AND e.exon_id = et.exon_id
      AND e.contig_id = c.internal_id
    ORDER BY t.transcript_id,e.exon_id
      , e.sticky_rank DESC
  };

  my $sth = $self->prepare( $query );
  $sth->execute();

  while( $hashRef = $sth->fetchrow_hashref() ) {
    if( ! exists $exons{ $hashRef->{exon_id} } ) {

      my $exon = $self->_exon_from_sth( $sth, $hashRef );
      $exons{$exon->dbID} = $exon;
    }
  }
  delete $self->{rchash};
  return values %exons;
}



# build an exon (possibly sticky exon) from given statement handle and
# retrieved row in hashref. return it. uses $self->{rchash} to store contig
# information. This should be cleared after leaving ExonAdaptor

sub _exon_from_sth {

  my ( $self, $sth, $hashRef ) = @_;
  my $sticky_length = 0;
  my $sticky_str = "";
  my $exon;

  if( $hashRef->{'sticky_rank'} >1 ) {	
    
    # sticky exon
    $exon = Bio::EnsEMBL::StickyExon->new();
    $exon->dbID($hashRef->{'exon_id'});
    # make first component exon
    my $component = $self->_new_Exon_from_hashRef($hashRef);

    $exon->add_component_Exon($component);
    $sticky_length += $component->length;
    $sticky_str    .= $component->seq->seq;

    $exon->phase($component->phase);
    $exon->end_phase($component->end_phase);
    $exon->adaptor($self);

    # continue while loop until we hit sticky_rank 1
    while( $hashRef = $sth->fetchrow_hashref() ) {
      my $component = $self->_new_Exon_from_hashRef($hashRef);

      $exon->add_component_Exon($component);
      $sticky_length += $component->length;
      $sticky_str     = $component->seq->seq . $sticky_str;

      if( $component->sticky_rank == 1 ) {
	$exon->contig( $component->contig );
	last;
      }
    }

    $exon->_sort_by_sticky_rank();

    # set start = 1 and end = length of sticky exon
    # build a minature sequence representing the sticky region and
    # attach

    $exon->start(1);
    $exon->end($sticky_length);
    $exon->strand( 1 );

    #my $rev = reverse(split(//,$sticky_str));
    my $tempseq = Bio::PrimarySeq->new( -display_id => 'artificial.sticky.exon'.$exon->dbID , '-seq' => $sticky_str);
    $exon->attach_seq($tempseq);

  } else {
    $exon = $self->_new_Exon_from_hashRef($hashRef);
    
  }

  return $exon;
}


sub _new_Exon_from_hashRef {
   my $self = shift;
   my $hashRef = shift;

   my $exon = Bio::EnsEMBL::Exon->new();
   $exon->start( $hashRef->{'seq_start'} );
   $exon->end( $hashRef->{'seq_end'} );
   $exon->strand( $hashRef->{'strand'} );
   $exon->phase( $hashRef->{phase} );
   $exon->end_phase( $hashRef->{end_phase} );
   $exon->dbID($hashRef->{'exon_id'});
   $exon->sticky_rank($hashRef->{'sticky_rank'});
   $exon->adaptor($self);

   if( !exists $self->{rchash}{$hashRef->{'contig_id'}} ) {
     $self->{rchash}{$hashRef->{contig_id}} = $self->db->get_Contig($hashRef->{'cid'});
   }

   $exon->attach_seq($self->{rchash}{$hashRef->{'contig_id'}}->primary_seq);
   $exon->contig( $self->{rchash}{$hashRef->{'contig_id'}} );
   $exon->seqname($hashRef->{'cid'});
   $exon->ori_start( $exon->start );
   $exon->ori_end( $exon->end );
   $exon->ori_strand( $exon->strand );

   # maybe we should cache this.
   
  return $exon;
}


=head2 fetch_evidence_by_Exon

 Title   : fetch_evidence_by_Exon
 Usage   : $exonAdaptor->fetch_evidence_by_Exon($exon)
 Function: Fetch evidence for this Exon. Attaches the evidence to the exon.
           .
 Returns : nothing
 Args    : 

=cut

sub fetch_evidence_by_Exon {
  my ( $self, $exon )  = @_;
 
  my $statement = "SELECT seq_start, seq_end, score,
                          strand, analysis, name, hstart, hend,
                          hid, evalue, perc_id, phase, end_phase
                   FROM supporting_feature 
		     WHERE exon_id = ".$exon->dbID;

  my $sth = $self->prepare($statement);
  $sth->execute || $self->throw("execute failed for supporting evidence get!");

  my @features;
  my $anaAdaptor = $self->db->get_AnalysisAdaptor;
  my $contig_id = $exon->contig->internal_id;
  
  while (my $rowhash = $sth->fetchrow_hashref) {
      my $analysis = $anaAdaptor->fetch_by_dbID( $rowhash->{analysis} );
      
      my $f = Bio::EnsEMBL::FeatureFactory->new_feature_pair();
      $f->set_all_fields($rowhash->{'seq_start'},
			 $rowhash->{'seq_end'},
			 $rowhash->{'strand'},
			 $rowhash->{'score'},
			 $rowhash->{'name'},
			 'similarity',
			 $contig_id,
			 $rowhash->{'hstart'},
			 $rowhash->{'hend'},
			 1, # hstrand
			 $rowhash->{'score'},
			 $rowhash->{'name'},
			 'similarity',
			 $rowhash->{'hid'});

      #
      # WARNING - assumming perl extensions, not C
      #

      $f->analysis($analysis);
	
      $f->validate;

      $exon->add_Supporting_Feature($f);
    }

  return 1;
}

=head2 fetch_overlapping_by_Exon

 Title   : fetch_overlapping_by_Exon
 Usage   : $exonAdaptor->fetch_overlapping_by_Exon($exon)
 Function: Fetch evidence for this Exon.
 Returns : ref to feature array. Doesnt change exon.
 Args    : 

=cut

sub fetch_overlapping_by_Exon {
  my ( $self, $exon )  = @_;
  my @result;

  # if exon is sticky, get supporting from components
  if( $exon->isa( 'Bio::EnsEMBL::StickyExon' )) {
    # sticky storing. Sticky exons contain normal exons ...

    my @componentExons = $exon->each_component_Exon();
    for my $componentExon ( @componentExons ) {
      my $component_features;

      $component_features = $self->fetch_overlapping_by_Exon( $componentExon );
      push( @result, @$component_features );
    }
    return \@result;
  }
                        
  my $statement = "SELECT contig, seq_start, seq_end, score,
                          strand, analysis, name, hstart, hend,
                          hid, evalue, perc_id, phase, end_phase
                   FROM feature 
                   WHERE contig = ".$exon->contig->internal_id."
                   AND seq_start <= ".$exon->end()."
                   AND seq_end >= ".$exon->start();


  my $sth = $self->prepare($statement);
  $sth->execute || $self->throw("execute failed for supporting evidence get!");

  my @features;
  my $anaAdaptor = $self->db->get_AnalysisAdaptor;

  while (my $rowhash = $sth->fetchrow_hashref) {
      my $analysis = $anaAdaptor->fetch_by_dbID( $rowhash->{analysis} );

#   Dont know if the following is necessary ....

#       if( $analysis->logic_name ne "Swall" &&
#           $analysis->logic_name ne "Vertrna" &&
#           $analysis->logic_name ne "Unigene" &&
#           $analysis->logic_name ne "TGE_e2g" &&
#           $analysis->logic_name ne "similarity_genewise" &&
#           $analysis->logic_name ne "combined_gw_e2g" ) {
#         next;
#       }

      my $f = Bio::EnsEMBL::FeatureFactory->new_feature_pair();
      $f->set_all_fields($rowhash->{'seq_start'},
                         $rowhash->{'seq_end'},
                         $rowhash->{'strand'},
                         $rowhash->{'score'},
                         $rowhash->{'name'},
                         'similarity',
                         $rowhash->{'contig'},
                         $rowhash->{'hstart'},
                         $rowhash->{'hend'},
                         1, # hstrand
                         $rowhash->{'score'},
                         $rowhash->{'name'},
                         'similarity',
                         $rowhash->{'hid'});

      #
      # WARNING - assumming perl extensions, not C
      #

      $f->analysis($analysis);
        
      $f->validate;
      push( @result, $f );
    }
  
  return \@result;
}


=head2 store

 Title   : store
 Usage   : $exonAdaptor->store($exonObject)
 Function: Stores the exon.
 Example : $exonAdaptor->store( $exon );
 Returns : nothing
 Args    : Exon or StickyExon

=cut

sub store {
  my ( $self, $exon ) = @_;

  if( ! $exon->isa('Bio::EnsEMBL::Exon') ) {
    $self->throw("$exon is not a EnsEMBL exon - not dumping!");
  }

  if( $exon->dbID && $exon->adaptor == $self ) {
      $self->warn("Exon with dbID ".$exon->dbID." has already got a dbID and is attached to this adaptor. No need therefore to store");
      return $exon->dbID();
  }


  my $exon_sql = q{
       INSERT into exon ( exon_id, contig_id, seq_start, seq_end, strand, phase, 
			  end_phase, sticky_rank)
		 VALUES ( ?, ?, ?, ?, ?, ?, ?,? )
		};
  my $exonst = $self->prepare($exon_sql);


  my $exonId = undef;

  if( $exon->isa( 'Bio::EnsEMBL::StickyExon' )) {
    # sticky storing. Sticky exons contain normal exons ...

    my @componentExons = $exon->each_component_Exon();
    for my $componentExon ( @componentExons ) {
      $exonst->execute( $exonId, $componentExon->contig_id,
			$componentExon->start(),
			$componentExon->end(),
			$componentExon->strand(),
			$componentExon->phase(),
			$componentExon->end_phase(),
			$componentExon->sticky_rank() );
      if( ! defined $exonId ) {
	$exonId = $exonst->{'mysql_insertid'};
	$exon->dbID($exonId);
	$exon->adaptor( $self );
      }
    }
  } else {
    # normal storing
    $exonst->execute( undef,$exon->contig_id,
		      $exon->start(),
		      $exon->end(),
		      $exon->strand(),
		      $exon->phase(),
		      $exon->end_phase(),
		      $exon->sticky_rank() );
    $exon->dbID($exonst->{'mysql_insertid'});
    #print STDERR "Assigning $exon with ",$exon->dbID,"\n";

    $exon->adaptor( $self );
  }

  # Now the supporting evidence
  # should be stored from featureAdaptor

 

  my $sth  = $self->prepare("
     INSERT INTO supporting_feature( 
        exon_id,contig_id,seq_start,seq_end,score,
        strand,analysis,name,hstart,hend,hid,hstrand) 
     VALUES(?,?,?,?,?,?,?,?,?,?,?,?) 
   ");


  my $anaAdaptor = $self->db->get_AnalysisAdaptor();

  FEATURE: foreach my $f ($exon->each_Supporting_Feature) {
	#print STDERR "Writing supporting feature ".$f->source_tag."\n";
	eval {
	    $f->validate();
	};

	if ($@) {
	    print(STDERR "Supporting feature invalid. Skipping feature\n");
	    next FEATURE;
	}

  	# my $analysisid = $feature_obj->write_Analysis($f->analysis);
	my $analysisid;
	if( !$f->analysis->adaptor == $anaAdaptor ) {
	  $analysisid = $f->analysis->dbID();
	} else {
	  $analysisid = $anaAdaptor->store( $f->analysis );
	  $f->analysis->dbID( $analysisid );
	}
	
	if ($f->isa("Bio::EnsEMBL::FeaturePair")) {
	    $sth->execute($exon->dbID(),
			  $f->seqname,
			  $f->start,
			  $f->end,
			  $f->score,
			  $f->strand,
			  $analysisid,
			  $f->source_tag,
			  $f->hstart,
			  $f->hend,
			  $f->hseqname,
			  $f->hstrand
			  );
	} else {
	    #$self->warn("Feature is not a Bio::EnsEMBL::FeaturePair");
	}
    }

  # Commented out until fully integrated into codebase
  # store exon frameshifts BUT only if there are some
  
#  if ( exists $exon->{'_frameshifts'} ) {
#
#   my $frameshift_sql = q{
#      INSERT INTO exon_frameshift 
#	( exon_id, frameshift_start, length )
#      VALUES ( ?, ?, ? )
#    };

#    my $frameshift_sth = $self->prepare($frameshift_sql);

#    for my $i ( 0 .. $#{$exon->{'_frameshifts'}} ) {

#      $frameshift_sth->execute( $exon->dbID,
#                               $exon->{'_frameshifts'}[$i][0],
#			       $exon->{'_frameshifts'}[$i][1]
#			     );
#    }
#  }

}

=head2 get_stable_entry_info

 Title   : get_stable_entry_info
 Usage   : $exonAdptor->get_stable_entry_info($exon)
 Function: gets stable info for exon and places it into the hash
 Returns : 
 Args    : 


=cut

sub get_stable_entry_info {
  my ($self,$exon) = @_;

  if( !defined $exon || !ref $exon || !$exon->isa('Bio::EnsEMBL::Exon') ) {
     $self->throw("Needs a exon object, not a $exon");
  }

  my $sth = $self->prepare("select stable_id,UNIX_TIMESTAMP(created),UNIX_TIMESTAMP(modified),version from exon_stable_id where exon_id = ".$exon->dbID);
  $sth->execute();

  my @array = $sth->fetchrow_array();
  $exon->{'_stable_id'} = $array[0];
  $exon->{'_created'}   = $array[1];
  $exon->{'_modified'}  = $array[2];
  $exon->{'_version'}   = $array[3];
  

  return 1;
}

sub remove {
  my $self = shift;
  my $exon = shift;
  
  if ( ! defined $exon->dbID() ) {
    return;
  }

  my $sth = $self->prepare( "delete from exon where exon_id = ?" );
  $sth->execute( $exon->dbID );

  $sth = $self->prepare( "delete from exon_stable_id where exon_id = ?" );
  $sth->execute( $exon->dbID );

  $sth = $self->prepare( "delete from supporting_feature where exon_id = ?" );
  $sth->execute( $exon->dbID );

  # uhh, didnt know another way of resetting to undef ...
  $exon->{dbID} = undef;
}


=head2 fetch_frameshifts

 Title   : fetch_frameshifts
 Usage   : exonAdaptor->fetch_frameshifts{exonObject)
 Function: populates the _frameshifts list with frameshift data
 Returns : populated _frameshifts list in exon object
 Args    : Exon

=cut

sub fetch_frameshifts {
  my ( $self, $exon ) = @_;

  my @frameshifts;

  my $frameshift_sql = "
    SELECT    frameshift_start, length
    FROM      exon_frameshift 
    WHERE     exon_id = " . $exon->dbID;

  my $sth = $self->prepare($frameshift_sql);

  $sth->execute || $self->throw("Execute failed for getting frameshifts in ExonAdaptor.pm!");

  while( my @arr = $sth->fetchrow_array() ) {
   push @{$exon->{'_frameshifts'}}, [$arr[0], $arr[1]];
  }
}


1;
