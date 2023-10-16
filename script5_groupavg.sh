#!/usr/bin/bash

rm -rf avg
mkdir -p avg

 for file in bedcounts/*;do
    noprefix=$(basename $file bedcounts/) #bedcounts/all_g1.bed > all_g1.bed
    outputname1=${noprefix/.bed/.txt} #all_g1.bed > all_g1.txt
    outputname2=${outputname1/all/avg} # all_g1.bed > avg_g1.bed
    num_columns=$(awk -F '\t' '{print NF}' $file | head -1 ) # obtian how many columns of a bedfile 
    awk -F '\t' -v num_columns=$num_columns '{
        sum_data=0;
        num_data=0;
        for( i = 6 ; i <= num_columns ; i++) {
          sum_data += $i;
          num_data ++
        }
        avg=sum_data/num_data;
        { print $4 "\t" $5 "\t" avg }
    }'  $file > avg/$outputname2
done