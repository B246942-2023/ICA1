#!/usr/bin/bash

rm -rf qualitysummary
mkdir -p qualitysummary
#need a dir to save my data, make sure it has no data before 

input_dir=fastq_decompress/*.zip 

for file in $input_dir; do
    filename_origin=$(basename $file .zip) # file nameis like this:Tco-999_2_fastqc.zip > Tco-999_2_fastqc
    filename_output=${filename_origin/_fastqc/_summary.txt} #I want it be Tco-999_2_summary.txt
    unzip -jp $file $filename_origin/summary.txt >qualitysummary/$filename_output #-j will not presever the structure of data -p can rename it.
done
