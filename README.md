# BiDirect_BIDS_Converter

## to do (needs implementation)  
- __optional__ "anonymization.csv"  
  - for changing folder names - left(old name), right (new name)  
- Markdown tables for Github/Gitlab  


This script sorts the DICOM data of the BiDirect study into BIDS file format using following libraries:

Dicom-to-NifTi conversion
- wrapper for Chris Rordens DCM2NII
- using system() command

File renaming  
- stringr (for the renaming stuff and regular expressions)  

Tidyverse (dplyr, tidyr, stringr)


## The algorithm works as described below:

- __dcm_converter.Rmd__  
  - it indices a _dicom_ root folder with subfolders _(dicoms/survey/participant)_  
    - based on DCM2NII  
    - anonymized output of compressed .nii.gz and a json file containing the nii header information  
  - the structure will be kept identical  
    - _(nii_temp/survey/participant)_  
  - output: but changing the root folder to _/nii_temp_  
- __json_indexing.Rmd__
  - here the algorithm looks for _.json_ files in the subfolders of the _/nii_temp_ folder
  - these are opened and appended (if they don't exist) into an _.csv_ file
  - take care, different sequences have different physical properties, so simple appending is not possible
  - here you have to select manually, which information of the variables you want to keep, and which to ignore
    - depends on scanner, sequence type, settings
- __json_wrangling.Rmd__
  - here the sequence names get cleaned and are brought to the BIDS standard format
- __/reports/plausible_sequences.Rmd__
  
- In a first step the converted nii images will be simply converted into the BIDS file structure in the _nii_temp_ folder. But the nii images are not in the standard nomenclature.

In a second step the _nii_ files in the _nii_temp_ folder will be moved and renamed to the final _nii_ folder.







## Prerequisites

_Computer_:
- R and RStudio
- actual versions of packages (this results in error messages in the beginning)
- Windows or Linux machine (both tested)

_Data_:
- to start: a path to a folder (working directory)
- this folder needs following substructure: 
  - working_directory/dicom/Baseline/Bidirect,00001
  - working_directory/dicom/Baseline/Bidirect,00002
  - working_directory/dicom/FollowUp/Bidirect,00001
  - ~/dicom/session_01/studyname,sub_id
- a dicom folder
  - containing the session folders
    - containing the dicom folders of each participant

## How to use it?

- the dicoms of your subjects need to be in one folder per timepoint!  
  




USING THE SCRIPTS

- synchronize the data of the external drive into the "Bidirect_Dicom/dicom" folder
- open the "scripts/dcm_converter.Rmd" script and run it step by step
  - common issues - working directory not set in the markdown document, then the files for conversion are not found
  - this script indices all subject folders in the dicom structure and compares them with a text document "dcm_converted.txt"
  - the subjects that are not mentioned in the "dcm_converted" are converted and appended at the document
- open the "scripts/json_indexing.Rmd" for indexing of the new json files containing sequence metainformationen and append it to the already scanned jsons
- open the "scripts/json_wrangling_2.Rmd" for cleaning and structuring of the filenames, run it step-by-step

- "reports/plausible implausibe" contain reports that use the outputted df of "json_wrangling_2" and shows you the actual data situation  


- move_files.Rmd 
  - moves plausible files to nii_BIDS
    - including duplicate sequences (these contain an "_a.nii")
  - copies duplicates to another folder for manual selection
  - moves
    - Smartbrains
    - Clinical scanner preprocessed sequences
    - Strange sequences





#### longitudinal codebook

Baseline -> ses1  
FollowUp1 -> ses2  
FollowUp2 -> ses3  
FollowUp2_Plus -> ses3_plus  
FollowUp3 -> ses4  
FollowUp3_Plus -> ses4_plus  

#### standard nomenclature 

__anat__:  
_T1w_  
_T2w_  
_T2_star_  
_T2_flair_  

__func__:  
_rest72/133_  
_epi_emo_faces_ (only at baseline) 

__dwi__:  
_DTI_  

__plus__ (only at ses3 and ses4, additional high resolution scans for 200 subjects):  
_T1w_mod_  
_T2w_mod_  
_T2_star_mod_  
_T2_flair_VISTA_  





You need a dictionary for renaming your sequence names to the _standard nomenclature_.










