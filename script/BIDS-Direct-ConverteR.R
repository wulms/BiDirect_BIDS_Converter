# BIDS-Direct-ConverteR
#setwd("/home/niklas/Coding/GITHUB-BiDirect_BIDS_Converter/")

print("Welcome to the BIDS-Direct-ConverteR")
Sys.sleep(3)


## general setup
source("functions/functions.R")

# pre-installation step
install_dcm2niix()

## settings
variables_environment$directories$setup$working_dir <- file.path(args)
 
# Create templates
create_templates()

## Stop 1: indexig input folders (dicom) - abort function - user edit needed
mapping_dicoms(variables_environment$directories$needed$dicom)



# dcm2niix conversion -----------------------------------------------------


diagnostics$dcm2nii_conversion_paths = dcm2nii_wrapper(
  input = diagnostics$dcm2nii_paths$dicom_folder,
  output = diagnostics$dcm2nii_paths$nii_temp,
  scanner_type = variables_user$LUT$study_info$scanner_manufacturer
)

dcm2nii_converter(diagnostics$dcm2nii_conversion_paths$nii,
                  diagnostics$dcm2nii_paths$nii_temp)

# json with sensitive information
dcm2nii_converter(
  diagnostics$dcm2nii_conversion_paths$json,
  str_replace(
    diagnostics$dcm2nii_paths$nii_temp,
    variables_environment$directories$needed$nii,
    variables_environment$directories$needed$json_sensitive
  )
)



# json path indexing and extraction ---------------------------------------

extract_json_metadata(variables_environment$directories$needed$json_sensitive)
diagnostics$json_data <- read_metadata()


# sequence extraction  ----------------------------------------------------
variables_user$LUT$sequences <- synchronise_lut_sequence(variables_environment$files$lut$lut_sequences)

# BIDS path creation
diagnostics$json_data <- apply_lut_sequence(diagnostics$json_data)







