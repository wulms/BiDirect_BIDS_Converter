# BiDirect_BIDS_Converter

This script sorts the DICOM data of the BiDirect study into BIDS file format using following libraries:

- dicom2niir (based on dicom2nii)
- 

Later on this tool is planned to be useable for longitudinal studies with multiple timepoints.

## How to use it?

- the dicoms off your subjects need to be in one folder per timepoint!
- in the root folder of that directory you need to specify a  
  - "timepoints.csv" - decoding your timepoint name and the standard name (your timepoint name), right (standard nomenclature)
  - "sequence.csv" - your sequence name to the standard nomenclature - left (your sequence name), right (standard nomenclature)
  - "string_replace.csv" - for removing redundant information in filenames - left (text to replace), right (replacement)
  - __optional__ "anonymization.csv" - for changing folder names - left(old name), right (new name)



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
_T2star_  
_FLAIR_  

__func__:  
_rest_  
_epi_bold_  

__dwi__:  
_DTI_  

__other__:  
_T2ffe_ 


You need a dictionary for renaming your sequence names to the _standard nomenclature_.

In a first step the converted nii images will be simply converted into the BIDS file structure in the _nii_temp_ folder. But the nii images are not in the standard nomenclature.

In a second step the _nii_ files in the _nii_temp_ folder will be moved and renamed to the final _nii_ folder.








