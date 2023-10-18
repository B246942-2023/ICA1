#!/usr/bin/bash
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP4:START!"
echo "STEP4:It will generate counts data in the form of bedfiles for each group"
read -n1 -sp "Press any key to continue......"
echo

#STEP4.1--------------------------------------------------------------------------------------------------------------#
#STEP4.1 Function : match filename to its group
echo "----------------------------------------------------------------------------------------------------------"
echo "Step4.1:Classify: Make a classification:files in folder(align_out) will be renamed with a group suffix"
echo "group total:15"
echo WT_Uninduced_0:group1
echo WT_Uninduced_24:group2
echo WT_Uninduced_48:group3
echo WT_Induced_24:group4
echo WT_Induced_48:group5
echo Clone1_Uninduced_0:group6
echo Clone1_Uninduced_24:group7
echo Clone1_Uninduced_48:group8
echo Clone1_Induced_24:group9
echo Clone1_Induced_48:group10
echo Clone2_Uninduced_0:group11
echo Clone2_Uninduced_24:group12
echo Clone2_Uninduced_48:group13
echo Clone2_Induced_24:group14
echo Clone2_Induced_48:group15
echo "
Running Time Estimation : 10s"
read -n1 -sp "Press any key to continue......"
echo 
rm -rf align_out_suffix
mkdir -p align_out_suffix
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

                if [[ "$Sampletype" == "$type1" && "$Treatment" == "$type2" && "$Time" == "$type3" ]];then #if match the type of files rename 
                    if [[ -e align_out/Tco-"$Samplenumber".bam ]];then # if that file exsit, some files have been removed by quality check.
                        cp align_out/Tco-"$Samplenumber".bam align_out_suffix/Tco-"$Samplenumber"_"$type1"_"$type2"_"$type3"_g"$grouptype".bam #add suffix to file to classify
                        echo "Tco-$Samplenumber is "$type1"_"$type2"_"$type3"_g"$grouptype"" 
                    fi
                fi


            done
        done
    done                
done < fastq/Tco2.fqfiles

echo "Successful!
Files in folder(align_out) have been added suffix to folder(align_out_suffix) "
#STEP4.2--------------------------------------------------------------------------------------------------------------#
#STEP4.2 Function: make bedfiles of each group using bedtools multicov 
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP4.2:Generate counts data: each group will have a bedfile containing its counts information "
echo "Running Time Estimation : 30s"
read -n1 -sp "Press any key to continue......"
echo 

rm -f TriTrypDB-46_TcongolenseIL3000_2019.bed
cp /localdisk/data/BPSM/ICA1/TriTrypDB-46_TcongolenseIL3000_2019.bed .
#cp bed file to local

rm -rf bedcounts
mkdir -p bedcounts
#bedcounts is where i want to output my data


bam_dir=align_out_suffix
bedfile=TriTrypDB-46_TcongolenseIL3000_2019.bed


rm -f $bam_dir/*.bai #rm all index created before(if there )
samtools index -M -@ 12 $bam_dir/*.bam
#-M means it can input multiply bamfiles at a time , -@ 12 means use 12 treads
#make index for all bam files first (must for multicov)

#generate bedfile by grouptype :g1,g2,g3,g4......g15
for ((i=1; i<=15;i++));do
    #Tco-122_WT_Uninduced_48_g3.bam (eg of bamfiles in bam_dir)
    {
        bedtools multicov -bed $bedfile -bams $bam_dir/*g$i.bam > bedcounts/all_g"$i".bed
    }& #only 15 groups ,no more than 15 threads in this section so don't worry about our 256 limit
done
wait
rm -f TriTrypDB-46_TcongolenseIL3000_2019.bed # I want my ICAfolder is clean.
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP4:Finished!
Results saved in folder(bedcounts)"