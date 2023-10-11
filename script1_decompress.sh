#!/usr/bin/bash

rm -rf fastq
rm -rf fastq_decompress
#remove original data
cp -r /localdisk/data/BPSM/ICA1/fastq .
#Copy our data to the local 
mkdir -p fastq_decompress
#make a dir for output

input_dir=fastq/*fq.gz
output_dir=fastq_decompress
#chose where i want to input and output my data

for file in $input_dir;do
    filename=$(basename $file)
    fastqc -t 4 $file -o $output_dir #-t :more threads make it faster
done


