#!/usr/bin/bash

#group total  15

while read -r line;do
    #SampleName	SampleType	Replicate	Time	Treatment	End1	End2
    #Tco230	Clone1	1	0	Uninduced	Tco-230_1.fq.gz	Tco-230_2.fq.gz
    Samplename=$(echo "$line" | awk -F'\t' '{print$1}') 
    Samplenumber=${Samplename/Tco/}  #Tco230 > 230
    Sampletype=$(echo "$line" | awk -F'\t' '{print$2}')
    Time=$(echo "$line" | awk -F'\t' '{print$4}')
    Treatment=$(echo "$line" | awk -F'\t' '{print$5}')
    
    #use three loops make to classify
    Sampletype_all=("WT" "Clone1" "Clone2") #first loop
    Time_all=("0" "24" "48") # loop2
    Treatment_all=( "Uninduced" "Induced") #loop3
    
    grouptype=0 # sufiix
    for type1 in ${Sampletype_all[@]};do
        for type2 in ${Treatment_all[@]};do
            for type3 in ${Time_all[@]};do
                #the loop is 3x2x3 = 18 times but we only have 15 tpyes of data ,cuz when T=0 Treatment must be uninduced
                if  [[ "$type3" != "0" || "$type2" != "Induced" ]];then # Not X-0-Induced
                    ((grouptype+=1)) #move to next group 
                fi
                #echo "#"$type1"_"$type2"_"$type3":group$grouptype" #debugging

                if [[ "$Sampletype" == "$type1" && "$Treatment" == "$type2" && "$Time" == "$type3" ]];then #match the type of files
                    if [[ -e align_out/Tco-"$Samplenumber".bam ]];then # if that file exsit, some files have been removed by quality check.
                        #mv align_out/Tco-"$Samplenumber".bam align_out/Tco-"$Samplenumber"_"$type1"_"$type2"_"$type3"_g"$grouptype".bam #add suffix to file to classify
                        echo "Tco-$Samplenumber is "$type1"_"$type2"_"$type3"_g"$grouptype"" 
                    fi
                fi


            done
        done
    done                
done < fastq/Tco2.fqfiles
#WT_Uninduced_0:group1
#WT_Uninduced_24:group2
#WT_Uninduced_48:group3
#WT_Induced_24:group4
#WT_Induced_48:group5
#Clone1_Uninduced_0:group6
#Clone1_Uninduced_24:group7
#Clone1_Uninduced_48:group8
#Clone1_Induced_24:group9
#Clone1_Induced_48:group10
#Clone2_Uninduced_0:group11
#Clone2_Uninduced_24:group12
#Clone2_Uninduced_48:group13
#Clone2_Induced_24:group14
#Clone2_Induced_48:group15