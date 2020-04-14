#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# start like this
# Rscript --vanilla plot_per_chip.R $FILENAME

FILENAME = args[1]
print(args[1])
print(FILENAME)


##################################################
## Project: Make CNV plot per chip
## Script purpose: all in one go
## Date: January 2019
## Author: Cornelis
##################################################

# prep input file
# setwd("/Users/blauwendraatc/Desktop/DESKTOP/Project_Manager/FOUNDIN/PLOT_per_chip/")
data = read.table("anno_file_neurochip.txt",header=T)
data2 = read.table(paste(FILENAME,".txt",sep=""),header=T)
MM = merge(data,data2,by.x='snpName',by.y='SNP_Name')
MM$Chr <- NULL
MM$Position <- NULL
MM_reorder <- MM[,c(3,4,2,1,5,6,7,8,9,10)]
final <- MM_reorder[order(MM_reorder$snpID),]
write.table(final, file=paste(FILENAME,".csv",sep=""), quote=FALSE,row.names=F,sep=",")
# prep scan file
tx  <- readLines("scan_file.txt")
tx2  <- gsub(pattern = "FILE", replace = paste(FILENAME), x = tx)
writeLines(tx2, con="scan_file_to_use.txt")
#install packages
#source("https://bioconductor.org/biocLite.R")
#biocLite("GWASdata")
# if already installed then continue below....
.libPaths("/usr/local/apps/R/3.6/site-library_3.6.1")
library(GWASdata)
# set working directory
# setwd("/Users/blauwendraatc/Desktop/DESKTOP/Project_Manager/FOUNDIN/PLOT_per_chip/")
# make data in format snpID must be the number 1-400000 end of list
# no chromosome 0 and 23=X, 24=XY (the pseudoautosomal region), 25=Y, 26=M
# optional step is filtering for gentrain score >0.7
# code adapted from here  https://bioconductor.org/packages/release/bioc/vignettes/GWASTools/inst/doc/DataCleaning.pdf
# https://bioc.ism.ac.jp/packages/3.2/bioc/manuals/GWASTools/man/GWASTools.pdf
#
#
### need three files to start:
# scan_file.txt
# anno_file.txt
# samplefile.csv which you describe in your scanfile 
#
# header of sample file should be
# chromosome,position,snpID,snpName,Sample.ID,Allele1,Allele2,GC_Score,BAlleleFreq,LogRRatio
#
#
# scanfile format:
# scanID scanName file
# 280 R1F6_817 R1F6_817.csv
scan.annotation <- read.table("scan_file_to_use.txt",header=T)
# snpfile format:
# snpID snpName chromosome position
# 1 MitoA8870G 1 569418
# 2 rs3094315 1 752566
# 3 rs3131972 1 752721
snp.annotation <- read.table("anno_file_neurochip.txt",header=T)
# name for gds file1
geno.file <- "file1.geno.gds"
# name for gds file2
baf.file <- "file1.baf.gds"
# path_for_genotyping_file make sure your file you want in here matches the file in "scan_file.txt"
path <- getwd()
##
## create a genotype file with "createDataFile"
# set columns numbers and names snp = snpname, a1 = allele1 and a2 = allele2
col.nums <- as.integer(c(4,6,7))
names(col.nums) <- c("snp", "a1", "a2")
# make gds file
genotype_gds <- createDataFile(path,filename = geno.file,file.type = "gds",
variables = "genotype",
snp.annotation = snp.annotation,
scan.annotation = scan.annotation,
sep.type = ",", # separating type either "," for csv files or "\t" for tab separated
skip.num = 1, # skip number of lines from header
col.total = 10, # total columns in file
col.nums=col.nums,
scan.name.in.file=0)
##
#create a BAF/LRR file with "createDataFile"
# set columns numbers and names snp = snpname, BAlleleFreq = guess... and LogRRatio = guess...
col.nums <- as.integer(c(4,9,10))
names(col.nums) <- c("snp", "BAlleleFreq", "LogRRatio")
intesi_gds <- createDataFile(path,filename = baf.file,file.type = "gds",
variables=c("BAlleleFreq", "LogRRatio"),
snp.annotation = snp.annotation,
scan.annotation = scan.annotation,
sep.type = ",",
skip.num = 1,
col.total = 10,
col.nums=col.nums,
scan.name.in.file=0)
##
# now plot, by first specifying the files you want and then select sample and then plot all chromosomes
blfile <- "file1.baf.gds"
bl <- GdsIntensityReader(blfile)
intenData <- IntensityData(bl)
genofile <- "file1.geno.gds"
geno <- GdsGenotypeReader(genofile)
genoData <- GenotypeData(geno)
scanAnnot <- ScanAnnotationDataFrame(scan.annotation)
scanID <- getScanID(scanAnnot, index=1)
# plot all chromosomes
pdf(paste(FILENAME,".pdf",sep=""))
for(j in c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25))
{
chromIntensityPlot(intenData=intenData, scan.ids=scanID,chrom.ids=j, type="BAF/LRR", info=paste(FILENAME),colorGenotypes=TRUE, genoData=genoData)
}
dev.off()
file.remove("file1.baf.gds")
file.remove("file1.geno.gds")
## done!
## great job!
