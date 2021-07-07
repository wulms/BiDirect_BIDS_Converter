#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)


# tests
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input directory of your study, containing 'dicom/session/subject' folders", call.=FALSE)
} 

# test if the path exists
if(!dir.exists(args)) {
  stop("Your path does not exist. Please choose a valid one.")
}

# test if the path contains a folder named "dicom"
if(!dir.exists(paste0(args, "/dicom"))){
    stop("Your path does not contain the 'dicom' root folder.")
}

dicomdirs = dir(path = args, pattern = "DICOM$|DICOMDIR$", recursive = TRUE)

# test if the path contains subfolders named "DICOM" or "DICOMDIR"
if(length(dicomdirs) == 0){
  stop("No folder 'DICOM' or 'DICOMDIR' found in your subject folders.")
}


# print the number of all dicom folders
print(paste("You have added ", length(dicomdirs), "DICOM directories to the converter."))
# start the converter
source(paste0(getwd(), "/script/BIDS-Direct-ConverteR.R"))







