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
#This is a mapping relation ship,cuz i used g1,g2,g3......as the suffix of my txt counts data.



#define an function so i can use it easily.
#it has 3 parameter: file1 file2 outputfile 
function foldchange() {
    local file1=$1
    local file2=$2
    local outputfile=$3
    #define my variable
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
}

#Genename   Description |foldchange|    foldchange  rate_of_change  Delta_counts    counts_x    counts_y
function manul() {
echo "----------------------------------------------------------------------------------------------------------"
echo "Here is the sturcture of your output file and how it is sorted:"
echo  " 9999 means state1  = 0 ----> state2 != 0"
echo  "-9999 means state1 != 0 ----> state2  = 0"
echo    
echo "Genename  Description  |foldchange|  foldchange  rate of change     Δcounts  File1_counts  File2_counts"
echo
echo "                       |foldchange|"
echo "                             |                  (rate of change)    Δcounts "
echo "                             |                                         |"
echo "                             |          9999            +∞%            |"
echo "                             |                                         v"
echo "                             |-------------------------------------------------"
echo "                             |                                         A"
echo "                             |         -9999            -∞%            |"
echo "                             |                                         |"
echo "                             |-------------------------------------------------"
echo "                             |                                         "
echo "                             |                           +/-%          "
echo "                             |                                         "
echo "                             V"
echo "----------------------------------------------------------------------------------------------------------"
}

function autoname () { # input g1 g2 and get WT_Uninduced_0_VS_WT_Uninduced_24.txt
    local name1=$1
    local name2=$2
    outname1=${grouptype["$name1"]}
    outname2=${grouptype["$name2"]}
    echo "$outname1"_VS_"$outname2.txt"
}

#------------------------------------------------------------------------------------------------
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP6:START!
STEP6:It will generate 6 group comparison data.
Running Time Estimation : 10s"
read -n1 -sp "Press any key to continue......"
echo

rm -rf final_results
mkdir -p final_results

g=avg/*g #rawmaterial_prefix , the name avgdata is like : avg_g7.txt

#1.Initial state
mkdir final_results/Initial_state
dir_1=final_results/Initial_state/
foldchange "$g"1* "$g"6* $dir_1$(autoname g1 g6)
foldchange "$g"1* "$g"11* $dir_1$(autoname g1 g11)
foldchange "$g"6* "$g"11* $dir_1$(autoname g6 g11)
manul >> $dir_1"manul.txt"
echo "Comparison1:Initial state
(Same:Time,Induction)(Var:cell line source)

WT_Uninduced_0__VS__Clone1_Uninduced_0  
WT_Uninduced_0__VS__Clone2_Uninduced_0
Clone1_Uninduced_0__VS__Clone2_Uninduced_0

purpose:
Is there any difference between them before we induce them?

Estimated result:
All of them are similar:The expression of a species are similar.Unless contamination and other situation happened.">>$dir_1"manul.txt"

#2.Effect of induction manipulation on wild samples(WT)
mkdir final_results/Effect_of_induction_on_WT
dir_2=final_results/Effect_of_induction_on_WT/
foldchange "$g"2* "$g"4* $dir_2$(autoname g2 g4)
foldchange "$g"3* "$g"5* $dir_2$(autoname g3 g5)
manul >> $dir_2"manul.txt"
echo "Comparison2:Effect of induction manipulation on wild samples(WT)
(Same:Time,RNAi)(Var:Induction)

WT_Uninduced_24__VS__WT_Induced_24
WT_Uninduced_48__VS__WT_Induced_48

Purpose:
Will induction change the expression of WT?

Estimated result:
Big difference should not happen, otherwise it means a failure of experiment design.">> $dir_2"manul.txt"

#3.Over time, the differences between the (CL1/CL2) and the WT
mkdir final_results/Differences_CL_WT_over_time
dir_3=final_results/Differences_CL_WT_over_time/
foldchange "$g"4* "$g"9* $dir_3$(autoname g4 g9)
foldchange "$g"5* "$g"10* $dir_3$(autoname g5 g10)
foldchange "$g"4* "$g"14* $dir_3$(autoname g4 g14)
foldchange "$g"5* "$g"15* $dir_3$(autoname g5 g15)
manul >> $dir_3"manul.txt"
echo "Comparison3:Over time, the differences between the (CL1/CL2) and the WT
(Same:Induction,Time)(Var:RNAi)

WT_Induced_24__VS__Clone1_Induced_24
WT_Induced_48__VS__Clone1_Induced_48
WT_Induced_24__VS__Clone2_Induced_24
WT_Induced_48__VS__Clone2_Induced_48

Purpose:
Check the hypothesis.

Estimated Result:
If the hypothesis is valid.
Two CL groups show the same tendency : some gene expression drop sharply,some gene increase.">>$dir_3"manul.txt"

#4.Over time, expression differences within CL1/CL2 due to the different induction situation
mkdir final_results/Differences_within_CL_Induction
dir_4=final_results/Differences_within_CL_Induction/
foldchange "$g"7* "$g"9* $dir_4$(autoname g7 g9)
foldchange "$g"8* "$g"10* $dir_4$(autoname g8 g10)
foldchange "$g"12* "$g"14* $dir_4$(autoname g12 g14)
foldchange "$g"13* "$g"15* $dir_4$(autoname g13 g15)
manul >> $dir_4"manul.txt"
echo "Comparison4:Over time, expression differences within CL1/CL2 due to the different induction situation
(Same:Group,Time,RNAi)(Var:Induction)

Clone1_Uninduced_24__VS__Clone1_Induced_24
Clone1_Uninduced_48__VS__Clone1_Induced_48
Clone2_Uninduced_24__VS__Clone2_Induced_24
Clone2_Uninduced_48__VS__Clone2_Induced_48

Purpose:
Is our RNAi construct working?

Estimated Result:
Some gene expression will drop sharply over time.
CL1 and CL2 show the same pattern.">>$dir_4"manul.txt"

#5.Difference in expression overtime after induction in the same group(CL1/CL2)
mkdir final_results/Expression_diff_over_time_CL_Induction
dir_5=final_results/Expression_diff_over_time_CL_Induction/
foldchange "$g"6* "$g"9* $dir_5$(autoname g6 g9)
foldchange "$g"9* "$g"10* $dir_5$(autoname g9 g10)
foldchange "$g"11* "$g"14* $dir_5$(autoname g11 g14)
foldchange "$g"14* "$g"15* $dir_5$(autoname g14 g15)
manul >> $dir_5"manul.txt"
echo "Comparison5:Difference in expression overtime after induction in the same group(CL1/CL2)
Effect of RNAi over time.
(Same:RNAi,Group,Induction)(Var:time)

Clone1_Uninduced_0__VS__Clone1_Induced_24
Clone1_Induced_24__VS__Clone1_Induced_48
Clone2_Uninduced_0__VS__Clone2_Induced_24
Clone2_Induced_24__VS__Clone2_Induced_48

Purpose:
What is the tendency in expression after induction in CL1/CL2?

Estimated Result:
Some gene expression increased which are more announced when 48h.
CL1 and CL2 show the same pattern.">>$dir_5"manul.txt"

#6.Differences between CL1 and CL2 in the same condition.
mkdir final_results/Differences_CL1_CL2_same_condition
dir_6=final_results/Differences_CL1_CL2_same_condition/
foldchange "$g"9* "$g"14* $dir_6$(autoname g9 g14)
foldchange "$g"10* "$g"15* $dir_6$(autoname g10 g15)
manul >> $dir_6"manul.txt"
echo "Comparison6:Differences between CL1 and CL2 in the same condition.
(Same:RNAi,Induction,Time)(Var:Group)

Clone1_Induced_24__VS__Clone2_Induced_24
Clone1_Induced_48__VS__Clone2_Induced_48

Purpose:
Is our biological replicates working well?(CL2 is the biological replicates of CL1)

Estimated Results:
They should be the same. Or it means contamination and other reasons which we don’t want.">>$dir_6"manul.txt"

manul 
read -n1 -sp "Press any key to continue...... "
echo
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP6:Finished!
All of the results have been put into folder(final_results.)
There is a manul in that folder to help you look through that data."