#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)




# print the number of all dicom folders
print(paste("You have added ", length(dicomdirs), "DICOM directories to the converter."))
# start the converter
source(paste0(getwd(), "/script/BIDS-Direct-ConverteR.R"))







