#!/usr/bin/bash

rm -f TriTrypDB-46_TcongolenseIL3000_2019.bed
cp /localdisk/data/BPSM/ICA1/TriTrypDB-46_TcongolenseIL3000_2019.bed .
#cp bed file to local

rm -rf bamcounts
mkdir -p bamcounts
#bamcounts is where i want to output my data

bedfile=TriTrypDB-46_TcongolenseIL3000_2019.bed
bamfile=align_out/Tco-964.bam


#bedtools coverage -a $bedfile -b $bamfile > Tco-964.bed
samtools index align_out/Tco-964.bam
bedtools multicov -bams $bamfile -bed $bedfile > x.bed



