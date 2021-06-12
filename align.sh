#!/bin/bash

# Create loop for 
while read p
do
file=$p
file2=`echo ${p%.fastq.gz} | sed 's/_1/_2.fastq.gz/g'`

echo ${file}
echo ${file2}

STAR --runThreadN 40 \
--runMode alignReads \
--readFilesCommand zcat \
--genomeDir Genome_dir \
--readFilesIn /path/to/file/${file} /path/to/file/${file2} \
--outSAMtype BAM Unsorted \
--outFileNamePrefix /path/to/Genome_dir/directory/${file%.fastq.gz}.bam \

done <listoffastqfiles.txt

for file in /path/to/Genome_dir/*.bamAligned.out.bam
do
samtools sort -@ 40 -O bam -T tmp ${file} -o ${file%%.us.bamAligned.out.bam}.sorted.bam
done

for file in /path/to/Genome_dir/*sorted.bam
do
samtools depth ${file} > /path/to/Genome_dir/${file}.csv
done
