#!/usr/bin/bash
echo "----------------------------------------------------------------------------------------------------------"
echo "PASS	Basic Statistics	Tco-106_1.fq.gz
PASS	Per base sequence quality	Tco-106_1.fq.gz
PASS	Per sequence quality scores	Tco-106_1.fq.gz
FAIL	Per base sequence content	Tco-106_1.fq.gz
PASS	Per sequence GC content	Tco-106_1.fq.gz
PASS	Per base N content	Tco-106_1.fq.gz
PASS	Sequence Length Distribution	Tco-106_1.fq.gz
PASS	Sequence Duplication Levels	Tco-106_1.fq.gz
WARN	Overrepresented sequences	Tco-106_1.fq.gz
PASS	Adapter Content	Tco-106_1.fq.gz"
echo "----------------------------------------------------------------------------------------------------------
This is an example of quality check data."


echo "----------------------------------------------------------------------------------------------------------"
read -n1 -sp "You are going to set your personalized choices.
Press any key to continue......"

#set a array for me to let the user set their choices
items=( "Basic Statistics" 
    "Per base sequence quality" 
    "Per sequence quality scores" 
    "Per base sequence content" 
    "Per sequence GC content" 
    "Per base N content" 
    "Sequence Length Distribution" 
    "Sequence Duplication Levels" 
    "Overrepresented sequences" 
    "Adapter Content" 
    )

declare -A choices #initialize an array to restore the user's choice
while true;do
    for item in "${items[@]}";do # searching loop and save the PASS data inputed by the user
        while true;do
        echo "----------------------------------------------------------------------------------------------------------" 
        echo "Do u NEED a PASS in $item? (y/n)"
        read choice
            case $choice in
                y)
                    choices["$item"]="PASS"
                    echo "Saved" 
                    break;;
                n)
                    choices["$item"]="*"
                    echo "Saved"
                    break;;
                *)   
                    echo "Wrong command , input again"
            esac
        done            
    done

    echo "----------------------------------------------------------------------------------------------------------

    YOUR CHOICES:" # print the choices of the user.
    for item in "${items[@]}"; do
        echo -e " ${choices["$item"]}\t$item "
    done

    echo

    while true;do
        echo "----------------------------------------------------------------------------------------------------------"
        echo "Please double-check your choices,otherwise we will redo it"
        echo " * means FAIL WARN and PASS are ALL acceptable"
        read -p "Are u sure now?(y/n):" judge
            case $judge in
                y)
                    break 2;; # we have two loop now
                n)
                    echo "Set your choices again"
                    break;;
                *)
                    echo "Wrong command , input again."
            esac
    done    
done
# echo "${choices[@]}" # debugging

echo "----------------------------------------------------------------------------------------------------------
Checking program will start
Running Time Estimation : 10s"
read -n1 -sp "Press any key to continue......"
echo 

for file in qualitysummary/*.txt ; do
    flag=true # it's a flag about whether the summary meet the pass requirements
    
    while IFS= read -r line;do #IFS is pretty important here, spent me 1hour for debugging ...
        PASS_NO=$(echo "$line" | awk -F"\t" '{print $1}')
        item=$(echo "$line" | awk -F"\t" '{print $2}')
        if [[ "${choices[$item]}" == "PASS"  &&  "$PASS_NO" != "PASS" ]];then #if user's choice is a PASS but that in the summary.txt is not 
            flag=false  # mark the file does not meet the requirement
            break
        fi
        
    done <"$file"
    
    if $flag;then
        cp $file good_quality/
    else
        cp $file bad_quality/
    fi
done