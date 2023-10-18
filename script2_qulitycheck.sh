#!/usr/bin/bash
echo "----------------------------------------------------------------------------------------------------------
STEP2:START!
STEP2:Qulity Check: make a decision about your data quality."
read -n1 -sp "Press any key to continue......"
echo

rm -rf qualitysummary
mkdir -p qualitysummary
#need a dir to save my data, make sure it has no data before 

input_dir=fastq_decompress/*.zip 

for file in $input_dir; do
    filename_origin=$(basename $file .zip) # file nameis like this:Tco-999_2_fastqc.zip > Tco-999_2_fastqc
    filename_output=${filename_origin/_fastqc/_summary.txt} #I want it be Tco-999_2_summary.txt
    unzip -jp $file $filename_origin/summary.txt >qualitysummary/$filename_output #-j will not presever the structure of data -p can rename it.
done

rm -rf good_quality
rm -rf bad_quality
mkdir good_quality
mkdir bad_quality
#make some dir to save my quality data,make sure they have no original data

while true ;do
    echo "----------------------------------------------------------------------------------------------------------"
    echo "There are 3 mode you can choose:

1.Check one by one : Check all summary.txt file one by one
2.Check by threhold : Set how many PASS do you want
3.Check by your personalized decison : Let you set which item you want it PASS (Recommand!!!!)"

    read -p "PLS input your mode: " mode
    echo
    case $mode in 
        1)
            ./script2.1*
            break;;
        2)
            ./script2.2*
            break;;
        3)
            ./script2.3*
            break ;;
        *)
            echo "Wrong command , input again ";;
    esac
done


good_num=$(ls good_quality | wc -l)
bad_num=$(ls bad_quality | wc -l)
echo "There are $good_num good quality files."
echo "There are $bad_num bad quality files."
#These codes are used for caculating the number of good/bad files.
read -n1 -sp "Press any key to continue......"
echo
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP2:Finished!"
echo "Results saved in folder(good_quality/bad_quality)"