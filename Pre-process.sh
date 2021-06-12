#!/bin/bash

#Loop through fastq files, and create variables "file" and "file2" representing R1 and R2 read pairs. Create variable "prefx" to annotate  

while read p
do
file=$p
file2=`echo ${p%.fastq.gz} | sed 's/_1/_2.fastq.gz/g'`
prefx=`echo ${p%_1.fastq.gz}`

echo ${file}
echo ${file2}

# Quality trim 
trim_galore --paired --retain_unpaired -q 30 /path/to/file/${file} /path/to/file/${file2}

# Merge read pairs 
flash -O -M 300 "${file%%.fastq.gz}_val_1.fq.gz" "${file2%%.fastq.gz}_val_2.fq.gz" -o ${prefx}


#Exract metrics from trimming reports

        for file in *trimming_report.txt

        do

        QCreadCountR1=`grep "Reads written (passing filters):" ${file} | head -n 1 | awk '{print $5 $6}'`
        QCbaseCountR1=`grep "Total written (filtered):" ${file} | head -n 1 | awk '{print $4 $6}'`
        QCreadCountR2=`grep "Reads written (passing filters):" ${file} | head -n 1 | awk '{print $5 $6}'`
        QCbaseCountR2=`grep "Total written (filtered):" ${file} | head -n 1 | awk '{print $4 $6}'`
        mergepairs=`echo $(cat "${file}out.extendedFrags.fastq" | wc -l)/4 | bc`

        awk '{print ${QCreadCountR1} "\t" ${QCbaseCountR1} "\t" ${QCreadCountR2} "\t" ${QCbaseCountR2} "\t" ${mergepairs} }' ${file} > "${file%%trimming_report.txt}trim_sum.txt"

        done

done<listoffastqfiles.txt
