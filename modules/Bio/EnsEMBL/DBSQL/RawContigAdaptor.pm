#
# EnsEMBL module for Bio::EnsEMBL::DBSQL::RawContigAdaptor
#
# Cared for by Imre Vastrik <vastrik@ebi.ac.uk>
#
# Copyright Imre Vastrik
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::EnsEMBL::DBSQL::RawContigAdaptor - MySQL database adapter class for EnsEMBL Feature Objects

=head1 SYNOPSIS



=head1 DESCRIPTION



=head1 CONTACT



=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are 
usually preceded with a _

=cut


# Let the code begin...

package Bio::EnsEMBL::DBSQL::RawContigAdaptor;

use vars qw(@ISA);
use strict;

# Object preamble - inheriets from Bio::Root::Object


use Bio::EnsEMBL::DBSQL::BaseAdaptor;
use DBI;
use Bio::EnsEMBL::DBSQL::DummyStatement;
use Bio::EnsEMBL::DBSQL::DBPrimarySeq;

use Bio::EnsEMBL::Clone;
use Bio::EnsEMBL::RawContig;


@ISA = qw(Bio::EnsEMBL::DBSQL::BaseAdaptor);

# new() is inherited from Bio::EnsEMBL::DBSQL::BaseAdaptor

sub get_internal_id_by_id
{
    my ($self, $id) = @_;
    my $sth = $self->db->prepare
    (
         "select internal_id from contig where id = '$id'"
    );
    my $res = $sth->execute;
    if(my $rowhash = $sth->fetchrow_hashref) {
	return $rowhash->{internal_id};
    } else {
	$self->warn("Could not find contig with id $id");
    }
}

sub get_id_by_internal_id
{
    my ($self, $internal_id) = @_;
    my $sth = $self->db->prepare
    (
         "select id from contig where internal_id = '$internal_id'"
    );
    my $res = $sth->execute;
    if(my $rowhash = $sth->fetchrow_hashref) {
	return $rowhash->{id};
    } else {
	$self->warn("Could not find contig with internal_id $internal_id");
    }
}

#  contig_id | name                | clone_id | length | offset | corder | dna_id | chromosome_id | international_name 

sub fetch_by_dbID {
  my $self = shift;
  my $dbID = shift;

  my $sth = $self->prepare( "SELECT contig_id, name, clone_id, length, 
                          offset, corder, dna_id, 
                          international_name
                   FROM contig
                   WHERE contig_id = $dbID" );
  $sth->execute();
  
  my ( $contig ) = _contig_from_sth( $sth );

  return $contig;
}

sub fetch_by_name {
  my $self = shift;
  my $name = shift;

  my $sth = $self->prepare( "SELECT contig_id, name, clone_id, length, 
                          offset, corder, dna_id, 
                          international_name
                   FROM contig
                   WHERE name = '$name'" );
  $sth->execute();
  
  my ( $contig ) = _contig_from_sth( $sth );

  return $contig;
}


sub fetch_by_clone {
  my $self = shift;
  my $clone = shift;

  my $clone_id = $clone->dbID;
  
  my $sth = $self->prepare( "SELECT contig_id, name, clone_id, length, 
                          offset, corder, dna_id, chromosome_id, 
                          international_name
                   FROM contig
                   WHERE clone_id = $clone_id" );

  my @res = _contig_from_sth( $sth );
  return \@res;
}


# mainly used from RawContig object. 
# Argument is a ready contig which needs its attributes filled

sub fetch {
  my $self = shift;
  my $contig = shift;
  
  my $dbID = $contig->dbID();

  my $sth = $self->prepare( "SELECT contig_id, name, clone_id, length, 
                          offset, corder, dna_id, international_name
                   FROM contig
                   WHERE contig_id = $dbID" );
  $sth->execute();
  
  my $aref = $sth->fetchrow_arrayref();
  if( defined $aref ) {
    _contig_from_arrayref( $contig, $aref );
  } else {
    $self->throw( "Couldnt fetch contig, unexpected .." );
  }
}


sub _contig_from_sth {
  my $self = shift;
  my $sth = shift;

  my @res = ();

  $sth->execute();
  while( my $aref = $sth->fetchrow_arrayref() ) {
    
    my $contig = Bio::EnsEMBL::RawContig->new( $aref->[0], $self );
    _contig_from_arrayref( $contig, $aref );

    push( @res, $contig );
  }

  return @res;
}



sub _contig_from_arrayref {
  my $self;
  my $contig;
  my $aref;

  my ( $contig_id, $name, $clone_id, $length, $offset, $corder, $dna_id,
       $international_name ) = @$aref;

    
  my $dbPrimarySeq = Bio::EnsEMBL::DBSQL::DBPrimarySeq->new
    ( $dna_id, $self->db() ); # ?
    
  my $clone = Bio::EnsEMBL::Clone->new( $self, $clone_id );

  $contig->clone( $clone );
  $contig->sequence( $dbPrimarySeq );
  $contig->length( $length );
  $contig->name( $name );
  $contig->offset( $offset );
  $contig->corder( $corder );
  $contig->international_name( $international_name );
  
}



1;
