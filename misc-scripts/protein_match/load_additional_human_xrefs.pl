#Contact: Emmanuel Mongin (mongin@ebi.ac.uk)

use strict;
use DBI;
use Getopt::Long;
use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Bio::EnsEMBL::DBSQL::DBEntryAdaptor;
use Bio::EnsEMBL::DBEntry;
use Bio::SeqIO;



my ( $host, $dbuser, $dbname, $dbpass, $port, $filename );

my %map;

GetOptions( "host=s", \$host,
	    "user=s", \$dbuser,
	    "pass=s", \$dbpass,
	    "port=i", \$port,
	    "dbname=s", \$dbname,
	    "file=s", \$filename
	  );

if( ! $filename ) {
  usage()
}

print STDERR "Connecting to $host, $dbname\n";


my $db = new Bio::EnsEMBL::DBSQL::DBAdaptor(
					    '-host'   => $host,
					    '-user'   => $dbuser,
					    '-dbname' => $dbname,
					    '-pass'   => $dbpass,
					    '-port'   => $port
					    );

my $adaptor = $db->get_DBEntryAdaptor();

print STDERR "Loading expression data\n";

open (AFFY, $filename ) || die "Can't open AFFY file";

while (<AFFY>) {
    chomp;
    my ($transl_id,$db1,$id) = split;
    
    if ($id ne "NULL") {
	my $dbentry = Bio::EnsEMBL::DBEntry->new
	    ( -adaptor => $adaptor,
	      -primary_id => $id,
	      -display_id => $id,
	      -version => 1,
	      -release => 1,
	      -dbname => $db1);
	$dbentry->status("XREF");
	print "$transl_id\t$db1\t$id\n";
	$adaptor->store($dbentry,$transl_id,"Translation");
    }
}

close(AFFY);

#print STDERR "Loading GKB mapping\n";

#open (GKB,"/acari/work1/mongin/mapping_11/human/Primary/gkb2.txt") || die "Can't open GKB data";

#while (<GKB>) {
#    chomp;
#    my ($sp,$id) = split;
#    my $db1 = "GKB";
#    my $query = "select o.ensembl_id from object_xref o, xref x where x.dbprimary_acc = '$sp' and x.xref_id = o.xref_id";
#    my $sth = $db->prepare($query);
#    $sth->execute();
#    while (my $transl_id = $sth->fetchrow) {
#       my $dbentry = Bio::EnsEMBL::DBEntry->new
#	    ( -adaptor => $adaptor,
#	      -primary_id => $id,
#	      -display_id => $id,
#	      -version => 1,
#	      -release => 1,
#	      -dbname => $db1);
#	$dbentry->status("XREF");
#	print STDERR "$transl_id\t$db1\t$id\n";
#
#       $adaptor->store($dbentry,$transl_id,"Translation");
#    }
#}

sub usage {
  print STDERR <<HELP

Usage: perl load_additional_human_xrefs.pl 
 -host  db connection detail
 -user 
 -pass
 -port
 -dbname
 -file filename 
    File with xrefs to upload

HELP
;

  exit();
}
