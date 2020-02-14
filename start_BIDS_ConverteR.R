#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input directory of your study, containing 'dicom/session/subject' folders", call.=FALSE)
} 

source("script/BIDS-Direct-ConverteR.R")







