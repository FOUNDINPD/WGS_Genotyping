# WGS_Genotyping
# Code for processing WGS and Genotyping data for FOUNDIN-PD project

## April 2020

### Couple folders in this repository

- Prioritization phase1 WGS
- Comparison with WGS
- Genetic integrity

### Prioritization phase1 WGS
Using the WGS samples were prioritized based on:

- WGS needs to be available

- Ancestry needs to be within 6SD of Europeans

- No relatedness among included individuals


### Prioritization phase2 genotypes (GENO)
This was done by:
a) comparing the day 0 (IPSC state) and day 65 (DA neuron state) with the blood derived donor WGS

b) inspection of each day 0 (IPSC state) and day 65 (DA neuron state) for large genomic events


### A) Comparison with WGS
Comparing overlapping variants between WGS data and NeuroChip and reporting mismatching alleles. Mismatches are plotted and if a large strecht of mismatches occurs then this will be easily identifiable in the generated pdfs.

Comparison_with_WGS.sh => This is the script to prepare the data

plot_differences_between_WGS_and_chip.R => This file is needed to run each chromosome for all samples

Example.pdf => Example of how output pdf looks like of chromosome 4 with an significant genomic event present

### B) Genetic integrity
Assessing the Genetic integrity of genotyping data based on B allele frequency and Log R ratio.
Prior to working here you need to have exported from genome-studio the CNV file more details are in Genetic_integrity_prep.sh

This script is using the R package: GWASdata 
Gogarten S (2019). GWASdata: Data used in the examples and vignettes of the GWASTools package. R package version 1.24.0.

Which uses GWASTools with reference Gogarten 2012: https://www.ncbi.nlm.nih.gov/pubmed/23052040

There are 5 files in this folder:

Genetic_integrity_prep.sh => This is the script to prepare the data

Genetic_integrity_run_all.sh => This is the script to run all samples

plot_per_chip.R => This file is needed to run each sample

anno_file_neurochip.txt => This file is needed for the annotation of the NeuroChip content

scan_file.txt => This file is needed for the input of the plot_per_chip.R script

Example.pdf => Example of how output pdf looks like


