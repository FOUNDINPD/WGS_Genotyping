#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# cd into a folder to make the individual .pdfs

# Reading in arguments and printing them to the terminal
CHROMOSOME = args[1]
print(args[1])
print(CHROMOSOME)

# Download the required packages
if (!require(tidyverse)) install.packages('tidyverse')
if (!require(data.table)) install.packages('data.table')
if (!require(dplyr)) install.packages('dplyr')
if (!require(ggplot2)) install.packages('ggplot2')

# Load the required packages
library(tidyverse)
library(data.table)
library(dplyr)
library(ggplot2)

# Read in the data, force new column names 
neuroX_ppmi <- fread("merge_NeuroX_PPMI_snplis.diff")
colnames(neuroX_ppmi) <- c("SNP", "FID", "IID", "NEW", "OLD")

neuroX_FOUNDIN <- fread("FOUNDIN_plink_day0only4.bim")
colnames(neuroX_FOUNDIN) <- c("Chrom", "SNP", "Pos.(in Morgans)", "Basepair", "Allele_1", "Allele_2")

# Left-join the data
merged_data = left_join(neuroX_ppmi, neuroX_FOUNDIN, by="SNP")

# head(merged_data)

# Subset data by chromosome
chr <- subset(merged_data, Chrom==args[1])

# Generate plot by chromosome
chr_plot <- ggplot(chr) +
  geom_point(aes(x = Basepair, y = as.factor(IID), alpha = 0.5), show.legend = F, size=0.05) + 
  ggtitle(paste("Chromosome", args[1], sep=" ")) +
  xlab("Position (Basepair)") + 
  ylab("PPMI ID") + 
  theme_light() + 
  theme(axis.text.y = element_text(face="bold", size=2, angle=45)) +
  theme(plot.title = element_text(hjust=0.5))

# Save high-quality plot to .pdf
ggsave(paste("PPMI.chr", args[1], ".pdf", sep=""), 
 plot = chr_plot,
 width = 10, height = 5, 
 units = "in", # other options c("in", "cm", "mm"), 
 dpi = 500)

