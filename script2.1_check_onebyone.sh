#!/usr/bin/bash


total_file=$(ls qualitysummary | wc -l)
current_file_checked=1
#I want make a echo which can tell user how many percent has they done ,now prepare the variable.

for file in qualitysummary/*.txt;do
    echo "----------------------------------------------------------------------------------------------------------"
    cat $file #show the summary first 
    while true;do #make infinte loops to check the input of user\
        echo "----------------------------------------------------------------------------------------------------------"
        read -p "Do you think its quality is good?(y/n/stoploop)
if stoploop u need to do them again from the beginning: " choice #ask for an input and save it to variable choice
        echo
        #ask the user to decide to data qulity.
        percent=$(echo "scale=2 ;($current_file_checked/$total_file)*100" | bc) #caculate the compeleted percentage (bc ,learned from google)
        echo " ----------------------------------------------------------------------------------------($current_file_checked/$total_file)$percent % compeleted"
        case $choice in # cp files to different folders according to the input choice
            "y") cp $file good_quality ; echo "Saved" ;break ;;
            "n") cp $file bad_quality ;echo "Saved"; break;;
            "stoploop") break 2 ;; #it can break twice
            *) echo "Wrong command,input again "
        esac
    done
    ((current_file_checked++))
done
if (( current_file_checked >= total_file )) ;then
    echo "Quality Check compeleted , CONGRADULATIONS!"
else
    echo "Mission failed , TRY AGAIN. "
fi
