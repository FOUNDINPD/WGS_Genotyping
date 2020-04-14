###########
# prep for plot per chip using R package GWASdata
##########

# GWASdata citation:
Gogarten S (2019). GWASdata: Data used in the examples and vignettes of the GWASTools package. R package version 1.24.0.

# prior to working here you need to have exported from genome-studio the CNV file

# this file should have the following header:
Sample ID
SNP Name
Allele1 - Forward
Allele2 - Forward
GC Score
Chr
Position
B Allele Freq
Log R Ratio
Theta
GT Score

# Note that usually the header start with something like this:

[Header]
GSGT Version    2.0.3
Processing Date 3/18/2020 7:05 PM
Content         Neuro_Consortium_v1-1_20015375_A1.bpm
Num SNPs        487374
Total SNPs      487374
Num Samples     226
Total Samples   226
File    1 of 226
[Data]

# PATH to working folder
cd $PATH/working/folder/

# check number of text files
ls | grep FinalReport | wc -l
# 226 which makes sense

# OPTIONAL
# update names of current files (because sometimes GenomeStudio export files in different names)
create list of all samples
ls | grep FinalReport > CNV_files.txt
mkdir CNV
mv *FinalReport* CNV	
mv CNV_files.txt CNV
cd CNV

# remove header from above note = 10 rows, if using different genotyping array the -487375 will be different
cat CNV_files.txt  | while read line
do 
   tail -487375 $line > short.$line
done
# add proper sample name...
ls | grep short | grep -v short_ > short_CNV_files.txt
# run loop
cat short_CNV_files.txt  | while read line
do 
   echo $line >> sample_names.txt
   head $line | cut -f 1 | head -2 | tail -1 >> sample_names2.txt
done
# merge
paste sample_names.txt sample_names2.txt > update_names.txt
# add in mv and save as .txt
sh update_names.txt
# clean-up folder
mkdir raw_files
mv clean_FOUNDIN_* raw_files
# DONE and ready for plot per chip

# make list of samples to include
ls | grep "_cnv.txt" > short_CNV_files_plot.txt
sed -i 's/.txt//g' short_CNV_files_plot.txt

###### then run all files:

# using this command:
sbatch --cpus-per-task=10 --mem=10 --mail-type=END --time=8:00:00 Genetic_integrity_run_all.sh

# which looks like this:
cat Genetic_integrity_run_all.sh

#!/bin/bash

# sbatch --cpus-per-task=10 --mem=10 --mail-type=END --time=8:00:00 Genetic_integrity_run_all.sh

module load plink
module load R

cat short_CNV_files_plot.txt  | while read line
do 
	# replace space with underscore
	sed -i 's/ /_/g' $line.txt
	# run all 
	Rscript --vanilla plot_per_chip.R $line
done

# the plot_per_chip.R has a couple files that it needs before working:
- scan_file.txt => file needed as sample input
- anno_file_neurochip.txt => annotation file based on NeuroChip content

# then the output is a .pdf file per input sample
# see example.pdf for an example pdf on how it looks like



