#!/usr/bin/bash
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP5:START!"
echo "STEP5:Group avg: It will generate the avg of technical replicates in the same group
Running Time Estimation: 0.1s"
read -n1 -sp "Press any key to continue......"
echo

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

echo "----------------------------------------------------------------------------------------------------------"
echo "STEP5:Finished!
Results saved in folder(avg)"