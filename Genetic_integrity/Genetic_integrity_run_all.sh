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

