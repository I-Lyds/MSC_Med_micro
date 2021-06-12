#!/bin/bash

while read p
do
file=$p
file2=`echo ${p%.fastq.gz} | sed 's/_1/_2.fastq.gz/g'`

echo ${file}
echo ${file2}

STAR --runThreadN 40 \
--runMode alignReads \
--readFilesCommand zcat \
--genomeDir IGH_out \
--readFilesIn /path/to/file/${file} /path/to/file/${file2} \
--outSAMtype BAM Unsorted \
--outFileNamePrefix /path/to/directory/${file%.fastq.gz}.us.bam \

done <IGH.txt

for file in /data/campbell/projects/Msc90gnms/bwa_alnmt/sam_files/star_out/IGH_str_bams/*.us.bamAligned.out.bam
do
samtools sort -@ 40 -O bam -T tmp ${file} -o ${file%%.us.bamAligned.out.bam}.bam
done

for file in /data/campbell/projects/Msc90gnms/bwa_alnmt/sam_files/star_out/IGH_str_bams/*_1.bam
do
samtools depth ${file} > /data/campbell/projects/Msc90gnms/bwa_alnmt/sam_files/star_out/IGH_str_bams/plotdpth/${file}.csv
done
