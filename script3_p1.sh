#!/usr/bin/bash

#first,their maybe some files are not in pairs (_1_,_2_),because the quality check, we should consider that possibility.
rm -rf lackpairs
mkdir -p lackpairs #I want mv them in to this folder then we make align in good_quality

lackfile=$(ls good_quality | awk 'BEGIN{FS="_"}{print $1"_"$3}' | sort | uniq -c | awk '{if( $1 == 1){print $2}}')
#Tco-122_1_summary.txt
#split the filename by the delimiter_ ,then print $1_$3 (Tco-122_summary.txt),remove the influence of _1_and _2_,then sort it | uniq -c will tell me how many "Tco-122_summary.txt" are there
#if that uniq -c is not 2 ,than means this file lacks its pairs, we are not able to make a Double-ended alignment
lackfile_num=$(echo "$lackfile" | wc -l) # Spend much time doing this count ,the important thing is that "" ,make the table can be counted
if [[ -z "$lackfile" ]]; then #judge the if lackfile is empty
    echo "All data are in pairs/No goodqualitydata ,let's align"
else #if there are unpair data, mv it to lackpairs folder
    echo "There are $lackfile_num unpaired data"
    echo "$lackfile"
    echo "These data(in good_quality folder) will be sent to "lackpairs" folder.Press any key to continue =v=" 
    read -n1 -s # -n1 :return when read the first input str ,-s :make the input undisplayed
    for misspair in $lackfile;do 
        rmname=$(basename $misspair _summary.txt) #name in lackfile is like  :Tco-124_summary.txt
        mv  good_quality/$rmname* lackpairs
        echo "$rmname has been sent to prison"
    done
    echo "rm finished , let's align" 
fi 