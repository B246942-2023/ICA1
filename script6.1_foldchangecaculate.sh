#!/usr/bin/bash
declare -A grouptype
grouptype["g1"]="WT_Uninduced_0"
grouptype["g2"]="WT_Uninduced_24"
grouptype["g3"]="WT_Uninduced_48"
grouptype["g4"]="WT_Induced_24"
grouptype["g5"]="WT_Induced_48"
grouptype["g6"]="Clone1_Uninduced_0"
grouptype["g7"]="Clone1_Uninduced_24"
grouptype["g8"]="Clone1_Uninduced_48"
grouptype["g9"]="Clone1_Induced_24"
grouptype["g10"]="Clone1_Induced_48"
grouptype["g11"]="Clone2_Uninduced_0"
grouptype["g12"]="Clone2_Uninduced_24"
grouptype["g13"]="Clone2_Uninduced_48"
grouptype["g14"]="Clone2_Induced_24"
grouptype["g15"]="Clone2_Induced_48"

file1=avg/avg_g7.txt
file2=avg/avg_g9.txt
outputfile=g7_g9.txt
rm -f $outputfile

echo -e "Genename\tDescription\t|foldchange|\tfoldchange\trate of change\tDelta_counts\tFile1_counts\tFile2_counts" > $outputfile
paste $file1 $file2 | awk -F"\t" '
BEGIN{ OFS = "\t";}{
    Delta_counts = $6 - $3 
    if      ( $3 == 0 && $6 != 0 ){ foldchange = 9999 ; rate_of_change = "+∞";}
    else if ( $3 == 0 && $6 == 0 ){ foldchange = 1; rate_of_change = "0";}
    else if ( $3 != 0 && $6 == 0 ){ foldchange = -9999 ; rate_of_change = "-∞";}
    else{
    foldchange = ($6 / $3);
        if (foldchange < 1){
            foldchange = - 1 / foldchange;
        }

        rate_of_change = (($6-$3)/$3)*100;
        rate_of_change = rate_of_change "%";
    }
    print $1,$2,(foldchange >= 0 ? foldchange : -foldchange),foldchange,rate_of_change,"Counts_Delta:"Delta_counts,"Counts_x:"$3,"Counts_y:"$6,(Delta_counts >= 0 ? Delta_counts : -Delta_counts);
}' | sort -t$'\t' -k3,3nr -k4,4nr -k5,5nr -k9,9nr -k6,6nr | awk -F"\t" 'BEGIN { OFS = "\t" } { print $1, $2, $3, $4, $5, $6 ,$7 ,$8 }'>> $outputfile
#The last awk is used to delete the 9th column(which used in sort but no need to print)
#The out put file's data structure is 
#Genename   Description |foldchange|    foldchange  rate_of_change  Delta_counts    counts_x    counts_y
echo
echo
echo "Here is the sturcture of your output file and how it is sorted:"
echo
echo
echo "Genename  Description  |foldchange|  foldchange  rate of change     Δcounts  File1_counts  File2_counts"
echo
echo "                       |foldchange|"
echo "                             |                  (rate of change)    Δcounts "
echo "                             |                                         |"
echo "                             |                          +∞%            |"
echo "                             |                                         v"
echo "                             |-------------------------------------------------"
echo "                             |                                         A"
echo "                             |                          -∞%            |"
echo "                             |                                         |"
echo "                             |-------------------------------------------------"
echo "                             |                                         |"
echo "                             |                           +/-%          |"
echo "                             |                                         v"
echo "                             V"

read -n1 -sp "Dear user ,make sure you have understood.Press any key to countinue......"
echo

less $outputfile