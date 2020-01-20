# BIDS files 

dataset_description <- list("Name" = "The BIDS-Direct-ConverteR study",
                            "BIDSVersion" = "1.1.0rc4",
                            "License" = "This dataset was made available by You.  \n We hope that the users of the data will acknowledge the BIDS-Direct-ConverteR team and Grant XXXX in any publications.",
                            "Authors" =  paste0("['Niklas Wulms', 'Sven Eppe', 'Klaus Berger', 'Heike Minnerup']"),
                            "HowToAcknowledge" = "Please cite publications in References and Links",
                            "Funding"= paste0("['Here comes the fund']"),
                            "ReferencesAndLinks"= paste0("[
    'Teismann, H., Wersching, H., Nagel, M., Arolt, V., Heindel, W., Baune, B. T., … Berger, K. (2014). Establishing the bidirectional relationship between depression and subclinical arteriosclerosis - rationale, design, and characteristics of the BiDirect Study. BMC Psychiatry, 14(1). https://doi.org/10.1186/1471-244X-14-174',
    'Teuber, A., Sundermann, B., Kugel, H., Schwindt, W., Heindel, W., Minnerup, J., … Wersching, H. (2017). MR imaging of the brain in large cohort studies: feasibility report of the population- and patient-based BiDirect study. European Radiology, 27(1), 231–238. https://doi.org/10.1007/s00330-016-4303-9',
    'nwulms, & wulms. (2019, October 2). wulms/BiDirect_BIDS_Converter: Runable script (Version 0.1). Zenodo. http://doi.org/10.5281/zenodo.3469539''
    ]"),
                            "DatasetDOI"= "Add here your DOI")

README <- "This dataset was acquired at the BiDirect study, Institute for Epidemiology and Social Medicine, University of Muenster, Germany.

Description: BiDirect study neuroimaging data in BIDS format

Please cite the following references if you use these data:

General Study information:
Teismann, H., Wersching, H., Nagel, M., Arolt, V., Heindel, W., Baune, B. T., … Berger, K. (2014). Establishing the bidirectional relationship between depression and subclinical arteriosclerosis - rationale, design, and characteristics of the BiDirect Study. BMC Psychiatry, 14(1). https://doi.org/10.1186/1471-244X-14-174

Neuroimaging Study information:
Teuber, A., Sundermann, B., Kugel, H., Schwindt, W., Heindel, W., Minnerup, J., … Wersching, H. (2017). MR imaging of the brain in large cohort studies: feasibility report of the population- and patient-based BiDirect study. European Radiology, 27(1), 231–238. https://doi.org/10.1007/s00330-016-4303-9

Code used for processing: dicom2nii conversion, file management and BIDS: 
nwulms, & wulms. (2019, October 2). wulms/BiDirect_BIDS_Converter: Runable script (Version 0.1). Zenodo. http://doi.org/10.5281/zenodo.3469539

2019-12-04: Initial release, added references.

This dataset is made available under XXXXX

We hope that all users 
of the data will acknowledge the BiDirect project and Grant 
XXXX in any publications."


CHANGES <- "1.0.0 2019-12-04 
	- initial release
	- BIDS converter working 
	- actual version containing all subjects up to 2019-11-18"
