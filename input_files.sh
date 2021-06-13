#!/bin/bash

# Create a loop to execute R script on chosen files listed in "listofRDfiles.txt"
while read p
do
cd ${p%%1.bam.csv}

Rscript --slave /path/to/R/script/Normalise_CN.R

cd ..

done <listofRDfiles.txt
