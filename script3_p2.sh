#!/usr/bin/bash

rm -rf Tcongo_genome
cp -r /localdisk/data/BPSM/ICA1/Tcongo_genome/ .

bowtie2-build Tcongo_genome/* Tcongo_genome/Tcongo_genome_index #only one file called  "TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta.gz"  in that folder
#build an index for align first , we put it in the Tcogo_genome folder