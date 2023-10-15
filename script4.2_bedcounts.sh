#!/usr/bin/bash

rm -f TriTrypDB-46_TcongolenseIL3000_2019.bed
cp /localdisk/data/BPSM/ICA1/TriTrypDB-46_TcongolenseIL3000_2019.bed .
#cp bed file to local

rm -rf bedcounts
mkdir -p bedcounts
#bedcounts is where i want to output my data


bam_dir=align_out
bedfile=TriTrypDB-46_TcongolenseIL3000_2019.bed


rm -f align_out/*.bai #rm all index created before(if there )
samtools index -M -@ 12 align_out/*.bam
#make index for all bam files first (must for multicov)

#generate bedfile by grouptype :g1,g2,g3,g4......g15
for ((i=1; i<=15;i++));do
    #Tco-122_WT_Uninduced_48_g3.bam (eg of bamfiles in bam_dir)
    {
        bedtools multicov -bed $bedfile -bams $bam_dir/*g$i.bam > bedcounts/all_g"$i".bed
    }& #only 15 groups ,no more than 15 threads in this section so don't worry about our 256 limit
done