###########
# code used to compare WGS with genotyping array data
##########

needed for this:
plink
WGS data (plink format)
Genotyping data (plink format)

Two approaches:

1) Global comparison using plink --genome option
2) Plotting chromosomes to assess not matching regions

'1) Global comparison using plink --genome option'
# merge data 
plink --bfile FOUNDIN_plink --bmerge wgshg38ppmi.july2018 --make-bed --out temp2  
# from log file:
# 487374 markers loaded from FOUNDIN_plink.bim.
# 20871744 markers to be merged from wgshg38ppmi.july2018.bim.
# Of these, 20557250 are new, while 314494 are present in the base dataset.
# 310579 more multiple-position warnings: see log file.
# Error: 154465 variants with 3+ alleles present.

# excluding 3+ alleles variants:
plink --bfile FOUNDIN_plink --exclude temp2-merge.missnp --make-bed --out FOUNDIN_plink_short
# 332909 variants and 226 people pass filters and QC.
plink --bfile FOUNDIN_plink_short --bmerge /data/CARD/projects/FOUNDIN_TEMP/PLINK/clean_FOUNDIN/WGS/wgshg38ppmi.july2018 \
--make-bed --out temp2
# from log file:
# 332909 markers loaded from FOUNDIN_plink_short.bim.
# 20871744 markers to be merged from
# /data/CARD/projects/FOUNDIN_TEMP/PLINK/clean_FOUNDIN/WGS/wgshg38ppmi.july2018.bim.
# Of these, 20711715 are new, while 160029 are present in the base dataset.

# filter data prior to pruning
plink --bfile temp2 --maf 0.05 --geno 0.05 --hwe 1E-6 --make-bed --out temp3
# 136217 variants and 360 people pass filters and QC.

# check for global relatedness 
plink --bfile temp3 --indep-pairwise 500 5 0.5 --out prune
plink --bfile temp3 --extract prune.prune.in --make-bed --out prune
# 91874 variants and 360 people pass filters and QC.

plink --bfile prune --genome --out FOUNDIN_plink_relatedness_with_WGS --min 0.05
# process and analyze FOUNDIN_plink_relatedness_with_WGS.genome

'2) Plotting chromosomes to assess not matching regions'

# make plot comparing large regions of mismatches between WGS and day0
### first make sure sample IDs are the same because then if you merge them plink actually compares them
scp FOUNDIN_plink.fam FOUNDIN_plink_ORIGINAL.fam
plink --bfile FOUNDIN_plink --keep DAY0_only.txt --make-bed --out FOUNDIN_plink_day0only
# 127 samples...
sed -i 's/_day0//g' FOUNDIN_plink_day0only.fam
# Then start merging with WGS
plink --bfile FOUNDIN_plink_day0only wgshg38ppmi.july2018 --out merge1 --make-bed
# Of these, 8 are new, while 126 are present in the base dataset.
# Makes sense because PPMISI57869 doesn't have WGS
# flip bad alleles not matching to WGS
plink --bfile FOUNDIN_plink_day0only --flip merge1-merge.missnp --make-bed --out FOUNDIN_plink_day0only2 
# merge again to check allele for allele flips
plink --bfile FOUNDIN_plink_day0only2 --bmerge wgshg38ppmi.july2018 --out merge2 --merge-mode 6 --make-bed
# remove variants that are bad + only keep samples of which WGS is present
plink --bfile FOUNDIN_plink_day0only2 --exclude merge2.missnp --out FOUNDIN_plink_day0only3 --make-bed \
--keep wgshg38ppmi.july2018.fam
# filter WGS data for NeuroChip variants
plink --bfile /data/CARD/projects/FOUNDIN_TEMP/PLINK/clean_FOUNDIN/WGS/wgshg38ppmi.july2018 \
--extract FOUNDIN_plink_day0only3.bim --make-bed --out genomes_stripped_to_neurochip --keep FOUNDIN_plink_day0only3.fam
# make sure all samples are what they are supposed to be and all sample switches are corrected...
# for example corrections can be:
sed -i 's/PPMISI4099/temp/g' FOUNDIN_plink_day0only3.fam 
sed -i 's/PPMISI57670/temp2/g' FOUNDIN_plink_day0only3.fam
sed -i 's/temp/PPMISI57670/g' FOUNDIN_plink_day0only3.fam 
sed -i 's/temp2/PPMISI4099/g' FOUNDIN_plink_day0only3.fam
# then do final merge
# 7 (no merge) Report mismatching nonmissing calls.
# FIRST PASS
plink --bfile FOUNDIN_plink_day0only3 --bmerge genomes_stripped_to_neurochip --out merge_NeuroChip_PPMI_snplis --merge-mode 7 --make-bed
# 486745 variants and 126 people pass filters and QC.
# this spits out this file -> merge_NeuroX_PPMI_snplis.diff
# with header NEW = GENOMES OLD = NEUROCHIP
# SNP                  FID                  IID      NEW      OLD 
# then remove SNPs that are wrong in all lines
# first remove double space because plink has the inconvenient output with double spaces
sed -i 's/  / /g' merge_NeuroChip_PPMI_snplis.diff # need to do this x5
## this is the file with the times each variant is error
cut -d " " -f 2 merge_NeuroChip_PPMI_snplis.diff | sort | uniq -c | sort -nk1 > variant_failure_count.txt
# now create variant list to exclude because of too many mismatches and likely a problem variant
# set here at 42 which is 33% based on N=126
awk '{if ($1 > 42) print $2;}' variant_failure_count.txt > variant_failure_count_EXCLUDE.txt
## this is the file with the times each SAMPLE is error
cut -d " " -f 3 merge_NeuroChip_PPMI_snplis.diff | sort | uniq -c | sort -nk1 > PPMIID_failure_count.txt
# most mismatches found N=138087 for this sample: PPMISI53423, but known problem with donor WGS so all good.

# SECOND PASS
# remove bad variants + PPMISI53423
plink --bfile FOUNDIN_plink_day0only3 --exclude variant_failure_count_EXCLUDE.txt \
--remove remove53423.txt --out FOUNDIN_plink_day0only4 --make-bed
# run merge again
plink --bfile FOUNDIN_plink_day0only4 --bmerge genomes_stripped_to_neurochip --out merge_NeuroChip_PPMI_snplis_V2 --merge-mode 7 --make-bed
sed -i 's/  / /g' merge_NeuroChip_PPMI_snplis_V2.diff # need to do this x5


# Then Running comparison plots for all chromosome based on the merge_NeuroChip_PPMI_snplis_V2.diff file

module load R
for chrnum in {1..22};
do
	Rscript --vanilla plot_differences_between_WGS_and_chip.R $chrnum
done
# DONE
