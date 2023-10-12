#!/usr/bin/bash
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
wait #make sure all the threads are finished before my  next command 

