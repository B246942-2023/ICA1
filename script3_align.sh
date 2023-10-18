#!/usr/bin/bash
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP3:START!
STEP3:Align:Mapping our fq reads onto the comple genome."
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP3.1:Pairs check:You may have removed some bad quality data in the STEP2, so some good data may not in pairs.
if some data are not in pairs, it will be romoved.
Running Time Estimation : 0.1s"
#first,their maybe some files are not in pairs (_1_,_2_),because the quality check, we should consider that possibility.
read -n1 -sp "Press any key to continue......" # -n1 :return when read the first input str ,-sp :make the input undisplayed and show some information
echo

rm -rf lackpairs
mkdir -p lackpairs #I want mv them in to this folder then we make align in good_quality

lackfile=$(ls good_quality | awk 'BEGIN{FS="_"}{print $1"_"$3}' | sort | uniq -c | awk '{if( $1 == 1){print $2}}')
#Tco-122_1_summary.txt
#split the filename by the delimiter_ ,then print $1_$3 (Tco-122_summary.txt),remove the influence of _1_and _2_,then sort it | uniq -c will tell me how many "Tco-122_summary.txt" are there
#if that uniq -c is not 2 ,than means this file lacks its pairs, we are not able to make a Double-ended alignment


lackfile_num=$(echo "$lackfile" | wc -l) # Spend much time doing this count ,the important thing is that "" ,make the table can be counted
if [[ -z "$lackfile" ]]; then #judge the if lackfile is empty
    echo "----------------------------------------------------------------------------------------------------------"
    echo "All data are in pairs ,ready for align"
    read -n1 -sp "Press any key to continue......"
    echo
else #if there are unpair data, mv it to lackpairs folder
    echo "There are $lackfile_num unpaired data"
    echo "$lackfile"
    echo "These data in folder(good_quality) will be sent to folder(lackpairs) .
    Press any key to continue......." 
    read -n1 -s # -n1 :return when read the first input str ,-s :make the input undisplayed
    for misspair in $lackfile;do 
        rmname=$(basename $misspair _summary.txt) #name in lackfile is like  :Tco-124_summary.txt
        mv  good_quality/$rmname* lackpairs
        echo "$rmname has been sent to prison(lackpairs folder)"
    done
    echo "Removement finished , ready for align" 
    read -n1 -sp "Press any key to continue......"
    echo
fi 

#######################################################################################################################################
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP3.2:Index: make a index of Tcongo_genome.
Running Time Estimation : 20 s"
read -n1 -sp "Press any key to continue......"
echo

rm -rf Tcongo_genome
cp -r /localdisk/data/BPSM/ICA1/Tcongo_genome/ .
bowtie2-build --threads 16 Tcongo_genome/* Tcongo_genome/Tcongo_genome_index #only one file called  "TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta.gz"  in that folder
#--threads 16 means 16 threads 
#build an index for align first , we put it in the Tcogo_genome folder
echo "Index built compeleted!"
#######################################################################################################################################
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP3.3:Align: Make an aligning with bowtie2
Running Time Estimation : 30s"
read -n1 -sp "Press any key to continue......"
echo

rm -rf align_out
mkdir -p align_out
thread_max=200 # Woo, an AMD 128 cores 256 threads processor! Never seen before LOL ,let's make it worth!
thread_now=0

#In this loop i want find the fq.gz name(in fastq folder) according to their summary.txt name in folder good_quality
for file in good_quality/*_1_summary.txt;do  #name in good_quality is like Tco-122_1_summary.txt
    filename_origin=$(basename $file _1_summary.txt)
    filename1="${filename_origin}_1.fq.gz" #  Tco-122_1>Tco-122_1.fq.gz ;; filename in fastq is like : Tco-122_1.fq.gz
    filename2="${filename1/_1.fq.gz/_2.fq.gz} " #make Tco-122_1.fq.gz > Tco-122_2.fq.gz
    outputname=$(basename $filename1 _1.fq.gz) # make the output name , use the name of file1 and remove _1.fq.gz
    
    {
        bowtie2 -x Tcongo_genome/Tcongo_genome_index -1 fastq/$filename1 -2 fastq/$filename2 | samtools view -bS | samtools sort -@2 -o align_out/$outputname.bam 
    }&  #-@ 2 make it run samtools with 2 cores ,it should not be too much 
        # & make it multithreads
    ((thread_now+=3)) # need 3 threads for fastqc each loop (1for bowtie 2 for samtool)
    #echo $thread_now #for debugging
    if ((thread_now>=thread_max));then
        wait # if there are too much we should wait(learnt from my friend google)
        thread_now=0
    fi
done
wait # IMPORTANT: We use multithreads before ,if there is no this wait ,the next line rm will start, so some threads can not work any more
rm -rf Tcongo_genome # make the homepage tidy.
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP3:Finished!"
echo "Results saved in folder(align_out)"