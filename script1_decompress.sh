#!/usr/bin/bash
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP1:START!
STEP1:decompress all fastqc files
Running Time Estimation : 20s"
read -n1 -sp "Press any key to continue......"

rm -rf fastq
rm -rf fastq_decompress
#remove original data
cp -r /localdisk/data/BPSM/ICA1/fastq .
#Copy our data to the local 
mkdir -p fastq_decompress
#make a dir for output

thread_max=200 # Woo, an AMD 128 cores 256 threads processor! Never seen before LOL ,let's make it worth!
thread_now=0
#I want to use multithreads to fast it. single thread need 10 mins OMG too slow!

input_dir=fastq/*fq.gz
output_dir=fastq_decompress
#chose where i want to input and output my data

for file in $input_dir;do
    filename=$(basename $file)
    {
        fastqc -t 2 $file -o $output_dir #-t 2 :more threads make it faster
    }& 
    ((thread_now+=2)) # need two threads for fastqc each loop
    
    if ((thread_now >= thread_max ));then #this loop just to make sure our threads would not tooo much 
        wait # if there are too much we should wait(learnt from my friend google)
        thread_now=0
    fi
done
wait #make sure all the threads are finished before my  next command 
echo "----------------------------------------------------------------------------------------------------------"
echo "STEP1:Successfull!
All files are saved in folder(fastq_decompress)"

