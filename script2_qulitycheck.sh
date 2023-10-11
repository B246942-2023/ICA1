#!/usr/bin/bash

rm -rf qualitysummary
input_dir=fastq_decompress/*.zip 

for file in $input_dir; do
    filename_origin=$(basename $file .zip) # file nameis like this:Tco-999_2_fastqc.zip > Tco-999_2_fastqc
    filename_output=${filename_origin/_fastqc/_summary.txt} #I want it be Tco-999_2_summary.txt
    unzip -j $file $filename_origin/summary.txt -d qualitysummary #-j will not presever the structure of data
    mv qualitysummary/summary.txt qualitysummary/$filename_output  # change it's name
done