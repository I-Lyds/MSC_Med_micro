#!/bin/bash
# Add the sample ID to the file prefix of gene copy number estimates
for d in *; do
  [[ -d "$d" ]] && cd "$d" || continue
  for f in *gene_num.csv; do
    mv -v -- "${f}" "${d}${f}"
  done
  cd -
done

# Use sample ID to annotate gene copy umber data by creating additional column
for file in *gene_num.csv; do awk '{print $0,FILENAME}' $file > ${file%%_gene_num.csv}_samples.csv ; done
find . -type f -name '*gene_num.csv' -exec rm {} +
for file in *samples.csv; do sed 's/gene_num.csv//g' $file > ${file%%samples.csv}gene_num.csv; done

# Open R to plot data for all samples 
R << RSCRIPT --save
# Load the required packages
library(tidyverse)
library(dplyr)
library(plyr)
library(ggplot2)
# Set working environment as the directory above 
setwd("/path/to/parent/directory/")
# Create variable for directory
mydir_test = "name_of_dir"
#Create vector of filenames
myfiles_test = list.files(path=mydir_test, pattern="*samples.csv")
# Set working environment as the directory containing copy number estimates for each sample
setwd("/path/to/directory/containing/samples/")
# Load data into vector listusing lapply
data <- lapply(myfiles_test, read.csv, stringsAsFactors = FALSE, header = TRUE, sep = " ")
# Use the sample names to identify data
names(data) = c(myfiles_test)
# Combine all samples 
combo_ann_test <- bind_rows(data_test)

# Plot the gene copy number estimation for all samples and write to pdf file
pdf("IGL_Gene_ann_var.pdf", width = 16, height = 10, title = "Box plots represent the variation in gene copies")
par(mfrow=c(2,2))
ggplot(stack(combo_ann_test), aes(x = ind, y = values)) + geom_boxplot() + theme(axis.text.x = element_text(angle=90, hjust=1))
dev.off()
q()
