# Populate the appropriate tables in an xref metadata database


################################################################################
# SPECIES

INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (9606,9606,  'homo_sapiens',            'human,hsapiens,homosapiens');
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (10090,10090, 'mus_musculus',            'mouse,mmusculus,musmusculus');
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (10116, 10116, 'rattus_norvegicus',       'rat,rnovegicus,rattusnorvegicus');
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (31033,31033, 'fugu_rubripes',           'pufferfish,fugu,frubripes,fugurubripes');
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (7165,7165,  'anopheles_gambiae',       'mosquito,anopheles,agambiae,anophelesgambiae');
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (7227, 7227, 'drosophila_melanogaster', 'drosophila,dmelongaster,drosophilamelanogaster' );
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (6239, 6239, 'caenorhabditis_elegans',  'elegans,celegans,caenorhabditiselegans');
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (6238, 6238, 'caenorhabditis_briggsae', 'briggsae,cbriggsae,caenorhabditisbriggsae');
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (7955, 7955, 'danio_rerio',             'zebrafish,danio,drerio,daniorerio' );
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (9598, 9598, 'pan_troglodytes',         'chimp,chimpanzee,ptroglodytes,pantroglodytes');
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (9031, 9031,  'gallus_gallus',           'chicken,chick,ggallus,gallusgallus' );
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (99883, 99883,'tetraodon_nigroviridis',  'tetraodon,tnigroviridis,tetraodonnigroviridis');
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (9913, 9913,  'bos_taurus',             'cow,btaurus,bostaurus');
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (9615, 9615,  'canis_familiaris',        'dog,doggy,cfamiliaris,canisfamiliaris');
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (8364, 8364,  'xenopus_tropicalis',        'pipid,pipidfrog,xenopus,xtropicalis,xenopustropicalis');
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (13616, 13616,  'monodelphis_domestica',        'opossum,monodelphis,mdomestica,monodelphisdomestica');
INSERT INTO species (species_id, taxonomy_id, name, aliases) VALUES (4932, 4932,  'saccharomyces_cerevisiae',  'yeast,saccharomyces,scerevisiae,saccharomycescerevisiae');

################################################################################
# SOURCES - types of data we can read

# "High level" sources that we will also download from (via source_url)

INSERT INTO source VALUES (1, "Uniprot/SWISSPROT", 1, 'Y',1);
INSERT INTO source VALUES (2, "Uniprot/SPTREMBL", 1, 'Y',1);
INSERT INTO source VALUES (3, "RefSeq_peptide", 1, 'Y',1);
INSERT INTO source VALUES (4, "RefSeq_dna", 1, 'Y',1);
INSERT INTO source VALUES (5, "IPI", 1, 'Y',2);
##INSERT INTO source VALUES (6, "UniGene", 1, 'Y',2);

# Other sources - used to create dependent xrefs, but not to upload from

INSERT INTO source VALUES (1010, 'EMBL', 1, 'N', 2);
INSERT INTO source VALUES (1020, 'MIM', 1, 'N', 2);
INSERT INTO source VALUES (1030, 'PDB', 1, 'N', 2);
INSERT INTO source VALUES (1040, 'protein_id', 1, 'N', 2);
INSERT INTO source VALUES (1050, 'PUBMED', 1, 'N', 2);
INSERT INTO source VALUES (1060, 'MEDLINE', 1, 'N', 2);
INSERT INTO source VALUES (1100, 'LocusLink', 1, 'N', 2);
INSERT INTO source VALUES (1110, 'EntrezGene', 1, 'N', 2);

INSERT INTO source VALUES (1070, 'GO', 1, 'Y',2);
INSERT INTO source VALUES (1080, 'MarkerSymbol', 1, 'Y',2);
INSERT INTO source VALUES (1090, 'HUGO', 1, 'Y',2);
INSERT INTO source VALUES (1200, 'RGD', 1, 'Y',2);
INSERT INTO source VALUES (1300, 'Interpro', 1, 'Y', 2);
INSERT INTO source VALUES (1400, 'ZFIN_ID', 1, 'Y', 2);
INSERT INTO source VALUES (1500, 'MIM2', 1, 'Y', 3);

INSERT INTO source VALUES (2000, 'CCDS', 1, 'Y', 4);

################################################################################
# Files to fetch data from

# --------------------------------------------------------------------------------
# UniProt (SwissProt & SPTrEMBL)

# Note currently no UniProt data for fugu, anopheles, c.briggsae or chicken.


###HUMAN
##       uniprot
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1, 9606,'ftp://ftp.ebi.ac.uk/pub/databases/SPproteomes/swissprot_files/proteomes/9606.SPC', '', now(), now(), "UniProtParser");

##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (3, 9606,'ftp://ftp.ncbi.nih.gov/refseq/H_sapiens/mRNA_Prot/human.protein.gpff.gz', '', now(), now(), "RefSeqGPFFParser");

##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (4, 9606,'ftp://ftp.ncbi.nih.gov/refseq/H_sapiens/mRNA_Prot/human.rna.fna.gz', '', now(), now(), "RefSeqParser");

##       GO
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1070, 9606,'ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/HUMAN/gene_association.goa_human.gz', '', now(), now(), "GOParser");

##       HUGO
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1090, 9606,'http://www.gene.ucl.ac.uk/public-files/nomen/ens4.txt http://www.gene.ucl.ac.uk/public-files/nomen/ens1.txt', '', now(), now(), "HUGOParser");

##      Interpro
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1300, 9606,'ftp://ftp.ebi.ac.uk/pub/databases/interpro/interpro.xml.gz', '', now(), now(), "InterproParser");

##      OMIM 
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1500, 9606,'ftp://ftp.ncbi.nih.gov/repository/OMIM/morbidmap', '', now(), now(), "MIMParser");

##      IPI
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (5, 9606,'ftp://ftp.ebi.ac.uk/pub/databases/IPI/current/ipi.HUMAN.fasta.gz', '', now(), now(), "IPIParser");

##      CCDS
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (2000, 9606,'/dummy/CCDS.txt', '', now(), now(), "CCDSParser");

##      UniGene
##INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (6, 9606,'ftp://ftp.ncbi.nih.gov/repository/UniGene/Hs.seq.uniq.gz ftp://ftp.ncbi.nih.gov/repository/UniGene/Hs.data.gz', '', now(), now(), "UniGeneParser");


###MOUSE
##      uniprot
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1, 10090, 'ftp://ftp.ebi.ac.uk/pub/databases/SPproteomes/swissprot_files/proteomes/10090.SPC', '', now(), now(), "UniProtParser");

##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (3, 10090,'ftp://ftp.ncbi.nih.gov/genomes/M_musculus/protein/protein.gbk.gz', '', now(), now(), "RefSeqGPFFParser");

##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (4, 10090,'ftp://ftp.ncbi.nih.gov/genomes/M_musculus/RNA/rna.gbk.gz', '', now(), now(), "RefSeqGPFFParser");

##      mgd (MGI -- MarkerSymbol)
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1080, 10090,'ftp://ftp.informatics.jax.org/pub/reports/MRK_SwissProt_TrEMBL.rpt', '', now(), now(), "MGDParser");

##      GO 
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1070, 10090,'ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE/gene_association.goa_mouse.gz', '', now(), now(), "GOParser");

##      IPI
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (5, 10090,'ftp://ftp.ebi.ac.uk/pub/databases/IPI/current/ipi.MOUSE.fasta.gz', '', now(), now(), "IPIParser");

##      UniGene
##INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (6, 10090,'ftp://ftp.ncbi.nih.gov/repository/UniGene/Mm.seq.uniq.gz ftp://ftp.ncbi.nih.gov/repository/UniGene/Mm.data.gz', '', now(), now(), "UniGeneParser");

###RAT
##      uniprot
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1, 10116, 'ftp://ftp.ebi.ac.uk/pub/databases/SPproteomes/swissprot_files/proteomes/10116.SPC', '', now(), now(), "UniProtParser");

##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (3, 10116,'ftp://ftp.ncbi.nih.gov/genomes/R_norvegicus/protein/protein.gbk.gz', '', now(), now(), "RefSeqGPFFParser");

##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (4, 10116,'ftp://ftp.ncbi.nih.gov/genomes/R_norvegicus/RNA/rna.gbk.gz', '', now(), now(), "RefSeqGPFFParser");

##      GO 
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1070, 10116,'ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/RAT/gene_association.goa_rat.gz', '', now(), now(), "GOParser");

##  RGD
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1200, 10116,'ftp://rgd.mcw.edu/pub/data_release/genbank_to_gene_ids.txt', '', now(), now(), "RGDParser");

##  IPI
##      IPI
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (5, 10116,'ftp://ftp.ebi.ac.uk/pub/databases/IPI/current/ipi.RAT.fasta.gz', '', now(), now(), "IPIParser");

##      UniGene
##INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (6, 10116,'ftp://ftp.ncbi.nih.gov/repository/UniGene/Rn.seq.uniq.gz ftp://ftp.ncbi.nih.gov/repository/UniGene/Rn.data.gz', '', now(), now(), "UniGeneParser");

###Zebrafish
##      uniprot
#until zebra fish has it's own .SPC file parse all.
#INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1, 7955, 'ftp://ftp.ebi.ac.uk/pub/databases/SPproteomes/swissprot_files/proteomes/7955.SPC', '', now(), now(), "UniProtParser");

INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1, 7955, 'ftp://ftp.ebi.ac.uk/pub/databases/uniprot/knowledgebase/uniprot_sprot.dat.gz', '', now(), now(), "UniProtParser");

INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1, 7955, 'ftp://ftp.ebi.ac.uk/pub/databases/uniprot/knowledgebase/uniprot_trembl.dat.gz', '', now(), now(), "UniProtParser");


##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (3, 7955,'ftp://ftp.ncbi.nih.gov/genomes/D_rerio/protein/protein.gbk.gz', '', now(), now(), "RefSeqGPFFParser");

##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (4, 7955,'ftp://ftp.ncbi.nih.gov/genomes/D_rerio/RNA/rna.gbk.gz', '', now(), now(), "RefSeqGPFFParser");

##      GO 
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1070, 7955,'ftp://ftp.geneontology.org/pub/go/gene-associations/gene_association.zfin.gz', '', now(), now(), "GOParser");

##      ZFIN
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1400, 7955,'http://zfin.org/data_transfer/Downloads/refseq.txt http://zfin.org/data_transfer/Downloads/swissprot.txt', '', now(), now(), "ZFINParser");

##      IPI
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (5, 7955,'ftp://ftp.ebi.ac.uk/pub/databases/IPI/current/ipi.BRARE.fasta.gz', '', now(), now(), "IPIParser");

##      UniGene
##INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (6, 7955,'ftp://ftp.ncbi.nih.gov/repository/UniGene/Dr.seq.uniq.gz ftp://ftp.ncbi.nih.gov/repository/UniGene/Dr.data.gz', '', now(), now(), "UniGeneParser");

###chicken
##      uniprot
# no chicken specific file!!!!
#INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1, 9031, 'ftp://ftp.ebi.ac.uk/pub/databases/SPproteomes/swissprot_files/proteomes/9031.SPC', '', now(), now(), "UniProtParser");

INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1, 9031, 'ftp://ftp.ebi.ac.uk/pub/databases/uniprot/knowledgebase/uniprot_sprot.dat.gz', '', now(), now(), "UniProtParser");

INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1, 9031, 'ftp://ftp.ebi.ac.uk/pub/databases/uniprot/knowledgebase/uniprot_trembl.dat.gz', '', now(), now(), "UniProtParser");

##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (3, 9031,'ftp://ftp.ncbi.nih.gov/genomes/Gallus_gallus/protein/protein.gbk.gz', '', now(), now(), "RefSeqGPFFParser");

##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (4, 9031,'ftp://ftp.ncbi.nih.gov/genomes/Gallus_gallus/RNA/rna.gbk.gz', '', now(), now(), "RefSeqGPFFParser");

##       GO
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1070, 9031,'ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/gene_association.goa_uniprot.gz', '', now(), now(), "GOParser");

##      UniGene
##INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (6, 9031,'ftp://ftp.ncbi.nih.gov/repository/UniGene/Gga.seq.uniq.gz ftp://ftp.ncbi.nih.gov/repository/UniGene/Gga.data.gz', '', now(), now(), "UniGeneParser");

###8364,  'xenopus_tropicalis'

#uniprot
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1, 8364, 'ftp://ftp.ebi.ac.uk/pub/databases/uniprot/knowledgebase/uniprot_sprot.dat.gz', '', now(), now(), "UniProtParser");

#uniprot
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1, 8364, 'ftp://ftp.ebi.ac.uk/pub/databases/uniprot/knowledgebase/uniprot_trembl.dat.gz', '', now(), now(), "UniProtParser");

##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (3, 8364,'ftp://ftp.ncbi.nih.gov/refseq/release/vertebrate_other/vertebrate_other1.protein.gpff.gz', '', now(), now(), "RefSeqGPFFParser");

INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (3, 8364,'ftp://ftp.ncbi.nih.gov/refseq/release/vertebrate_other/vertebrate_other2.protein.gpff.gz', '', now(), now(), "RefSeqGPFFParser");

INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (3, 8364,'ftp://ftp.ncbi.nih.gov/refseq/release/vertebrate_other/vertebrate_other3.protein.gpff.gz', '', now(), now(), "RefSeqGPFFParser");

##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (4, 8364,'ftp://ftp.ncbi.nih.gov/refseq/release/vertebrate_other/vertebrate_other1.rna.fna.gz', '', now(), now(), "RefSeqParser");
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (4, 8364,'ftp://ftp.ncbi.nih.gov/refseq/release/vertebrate_other/vertebrate_other2.rna.fna.gz', '', now(), now(), "RefSeqParser");
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (4, 8364,'ftp://ftp.ncbi.nih.gov/refseq/release/vertebrate_other/vertebrate_other3.rna.fna.gz', '', now(), now(), "RefSeqParser");

##      UniGene
##INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (6, 8364,'ftp://ftp.ncbi.nih.gov/repository/UniGene/Str.seq.uniq.gz ftp://ftp.ncbi.nih.gov/repository/UniGene/Str.data.gz', '', now(), now(), "UniGeneParser");

### Dog

INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1, 9615, 'ftp://ftp.ebi.ac.uk/pub/databases/uniprot/knowledgebase/uniprot_sprot.dat.gz', '', now(), now(), "UniProtParser");

INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1, 9615, 'ftp://ftp.ebi.ac.uk/pub/databases/uniprot/knowledgebase/uniprot_trembl.dat.gz', '', now(), now(), "UniProtParser");

##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (3, 9615,'ftp://ftp.ncbi.nih.gov/genomes/Canis_familiaris/protein/protein.gbk.gz', '', now(), now(), "RefSeqGPFFParser");

##       refseq
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (4, 9615,'ftp://ftp.ncbi.nih.gov/genomes/Canis_familiaris/RNA/rna.gbk.gz', '', now(), now(), "RefSeqGPFFParser");

##       GO
INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (1070, 9615,'ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/gene_association.goa_uniprot.gz', '', now(), now(), "GOParser");

##      UniGene
##INSERT INTO source_url (source_id, species_id, url, checksum, file_modified_date, upload_date, parser) VALUES (6, 9615,'ftp://ftp.ncbi.nih.gov/repository/UniGene/Cfa.seq.uniq.gz ftp://ftp.ncbi.nih.gov/repository/UniGene/Cfa.data.gz', '', now(), now(), "UniGeneParser");

################################################################################

