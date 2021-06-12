#!/bin/bash

# Loop through fastq files, and create variables "file" and "file2" representing R1 and R2 read pairs.
while read p
do
file=$p
file2=`echo ${p%.val_2.fq.gz} | sed 's/_1/_2.val_2.fq.gz/g'`

echo ${file}
echo ${file2}

# Run STAR aligner on each mate pair

STAR --runThreadN 40 \
--runMode alignReads \
--readFilesCommand zcat \
--genomeDir Genome_dir \
--readFilesIn /path/to/file/${file} /path/to/file/${file2} \
--outSAMtype BAM Unsorted \
--outFileNamePrefix /path/to/Genome_dir/directory/${file%.val_2.fq.gz}.bam \

done <listoffastqfiles.txt

# Sort the bam files

for file in /path/to/Genome_dir/*.bamAligned.out.bam
do
samtools sort -@ 40 -O bam -T tmp ${file} -o ${file%%.us.bamAligned.out.bam}.sorted.bam
done

# Extract read depth (RD) data using samtools

for file in /path/to/Genome_dir/*sorted.bam
do
samtools depth ${file} > /path/to/Genome_dir/Depth_files/${file}.csv
done

#Make a list of the samples

ls | grep '.csv' > listofRDfiles.txt

# Loop through samples, to first create directories, and produce reference  .
while read p;
do mkdir -- "${p%1.bam.csv}"; mv -- "$p" "${p%1.bam.csv}"
done <listofRDfiles.txt

#Loop through samples to create a reference file for expected read depth
while read p
do
cd ${p%%1.bam.csv}


       for file in *bam.csv; do awk ' $2 >= 203584  && $2 <= 203906 ' $file > IGKC.ref.csv; done

      cd ..

done <listofRDfiles.txt

#Loop through files to annotate read depth positions with gene coordinates
while read p
do
cd ${p%%1.bam.csv}
awk '{print "11" "\t" $2-1"\t"$2"\t"$3}' $p | bedtools intersect -a /path/to/gene_coordinates/file.bed -b stdin -wb | awk '{print $1"\t"$3"\t"$8"\t"$4 }' > gene_annotated_positions.bed
cd ..
done < listofRDfiles.txt


