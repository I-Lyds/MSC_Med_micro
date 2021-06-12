#Load dependancies
library(tidyverse)
library(dplyr)
library(plyr)
library(ggplot2)

# Set working environment
getwd()
# Load reference gene data for expected coverage calculations
refgene <- read.csv("IGH.ref.csv", stringsAsFactors = FALSE, header = FALSE, sep = "\t")[ ,2:3]
# Load annotated read depth data
gene_annotated <- read.csv("gene_annotated_positions.bed", stringsAsFactors = FALSE, header = FALSE, sep = "\t")
# Use aggregate function to rearrange data according to the mean coverage of given gene coordinates
gene_means <- aggregate(.~ V4, mean, data=gene_annotated)
colnames(gene_means)=c("Gene","chr","Position","Depth")
# Calculate expected depth using average the coverage of reference gene
avgval<- group_by(refgene, V3) %>% summarize(m = mean(V3))
refavg<- avgval$m
# Create division function
division <- function(x) {
x /  refavg}
# Duplicate dataframe with normalised copy number (CN) values
gene_means2 <- gene_means
gene_means2$Depth <- gene_means2$Depth/refavg

# Plot normalised gene CN values and write to pdf file
pdf("Relative_CN_per_gene.pdf", width = 16, height = 10)
par(mfrow=c(2,2))
ggplot(gene_means2, aes(Gene,Depth)) + geom_bar(stat='identity') + theme(axis.text.x = element_text(angle=90, hjust=1, size=5)) + ggtitle("Normalised read depth at the IGH locus") + xlab("Gene") + ylab("Normalised Read Depth")
dev.off()

# Write normalised depth 
gene_means3 <- gene_means2[,c("Gene","CN")]
write.table(gene_means3, file = "gene_num.csv", append = FALSE, sep = " ", dec = ".", row.names = FALSE, col.names = TRUE)
