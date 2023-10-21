#!/usr/bin/bash

while true;do #infinite loop for inputting
    echo "----------------------------------------------------------------------------------------------------------"
    read -p "How many PASS is acceptable(Threhold)? From 0 to 10(Recommend:7) :" threhold #let user input his threhold of PASS
    case $threhold in
        [0-9]|10 ) 
            break ;; #it can not be [0,10],this only will match 0 and 1
        *) 
            echo "pls input a correct number" ;;
    esac
done

for file in qualitysummary/*.txt;do
    num_pass=$(grep "PASS" $file | wc -l) # caculate how many PASS in the file
    #echo "$num_pass" for debugging
    if (( num_pass > threhold )) ;then #if match the requirements put them into goodquality dir, otherwise put them in badquality
        cp $file good_quality
    else
        cp $file bad_quality
    fi
    #echo 1 for debugging
done

echo "Quality Check compeleted , CONGRADULATIONS! "
