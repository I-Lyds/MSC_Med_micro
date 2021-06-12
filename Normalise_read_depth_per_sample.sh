library(tidyverse)
library(dplyr)
library(plyr)
library(ggplot2)

getwd()

refgene <- read.csv("IGH.ref.csv", stringsAsFactors = FALSE, header = FALSE, sep = "\t")[ ,2:3]

gene_annotated <- read.csv("gene_annotated_positions.bed", stringsAsFactors = FALSE, header = FALSE, sep = "\t")

gene_means <- aggregate(.~ V4, mean, data=gene_annotated)

colnames(gene_means)=c("Gene","chr","Position","Depth")

avgval<- group_by(refgene, V3) %>% summarize(m = mean(V3))

refavg<- avgval$m

division <- function(x) {
x /  refavg}

gene_means2 <- gene_means

gene_means2$Depth <- gene_means2$Depth/refavg


pdf("Est_CNVs.pdf", width = 16, height = 10, title = "Est_CNVs")
par(mfrow=c(2,2))
ggplot(gene_means2, aes(Gene,Depth)) + geom_bar(stat='identity') + theme(axis.text.x = element_text(angle=90, hjust=1, size=5))
