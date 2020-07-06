###########
# Using WGS data to prioritize IPSC lines
##########

Phase1: Initial prioritization of PPMI (n=135) including criteria:
- WGS needs to be available
- Genetid Ancestry needs to be homogeneous for subsequent analysis and therefore within 6SD of Europeans
- No relatedness among included individuals

Most code is based on general GWAS scripts from here: https://github.com/neurogenetics/GWAS-pipeline

'WGS needs to be available:'
Downloaded PPMI WGS from LONI database and subset samples with IPSC line available. 
Using PLINK (v1.9) (Chang et al. 2015) to process the data.
plink --bfile wgshg38ppmi.july2018 --keep PPMI_IPSC.txt --make-bed --out PPMI_IPSC_WGS

One sample has no WGS available

'Genetid Ancestry needs to be homogeneous for subsequent analysis and therefore within 6SD of Europeans'
# following general workflow from https://github.com/neurogenetics/GWAS-pipeline
# Merge data with HapMap populations (Consortium and †The International HapMap Consortium 2003)
plink --bfile wgshg38ppmi.july2018 --extract HAPMAP_hg19_new.bim --make-bed --out hapmap_snps_only 
plink --bfile hapmap_snps_only --bmerge HAPMAP_hg19_new --out hapmap3_bin_snplis --make-bed
plink --bfile hapmap_snps_only --flip hapmap3_bin_snplis-merge.missnp --make-bed --out hapmap_snps_only3
plink --bfile hapmap_snps_only3 --bmerge HAPMAP_hg19_new --out hapmap3_bin_snplis --make-bed
plink --bfile hapmap_snps_only3 --exclude hapmap3_bin_snplis-merge.missnp --out hapmap_snps_only4 --make-bed
plink --bfile hapmap_snps_only4 --bmerge HAPMAP_hg19_new --out hapmap3_bin_snplis --make-bed
# create PC’s
plink --bfile hapmap3_bin_snplis --geno 0.01 --out pca --make-bed --pca 4
# adding in sample origins
grep "EUROPE" pca.eigenvec > eur.txt
grep "ASIA" pca.eigenvec > asia.txt
grep "AFRICA" pca.eigenvec > afri.txt
grep -v -f eur.txt pca.eigenvec | grep -v -f asia.txt | grep -v -f afri.txt > new_samples.txt
cut -d " " -f 3 hapmap_snps_only.fam > new_samples_add.txt
paste new_samples_add.txt new_samples.txt > new_samples2.txt
paste eur_add.txt eur.txt > euro.txt
paste asia_add.txt asia.txt > asiao.txt
paste afri_add.txt afri.txt > afrio.txt
cat new_samples2.txt euro.txt asiao.txt afrio.txt > pca.eigenvec2
# R script for PCA plotting and filtering
R < PCA_in_R.R --no-save  
# Figure from R plotting PC1 vs PC2
# 7 samples with a non-European ancestry

'No relatedness among remaining included individuals'
Remaining individuals is (135-1-7=) 127
plink --bfile hapmap3_bin_snplis --keep PPMI_IPSC_euro.txt --make-bed --geno 0.01 --maf 0.05 --out temp
plink --bfile temp --maf 0.05 --geno 0.05 --hwe 1E-6 --make-bed --out temp2 
plink --bfile temp2 --indep-pairwise 500 5 0.5 --out prune 
plink --bfile temp2 --extract prune.prune.in --make-bed --out prune 
plink --bfile prune --genome --out PPMI_only_PCA --min 0.05

# Six pairs showed first degree relative relatedness. From each pair 1 sample was excluded.


