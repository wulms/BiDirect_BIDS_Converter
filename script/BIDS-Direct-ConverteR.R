# BIDS-Direct-ConverteR
#setwd("/home/niklas/Coding/GITHUB-BiDirect_BIDS_Converter/")


# args = "/home/niklas/BIDS_test/"

## general setup
source("functions/functions.R")

render_asci_art("asci/logo.txt")

# pre-installation step
install_dcm2niix()

## settings
variables_environment$directories$setup$working_dir <- file.path(args)
 
# Create templates
create_templates()

## Stop 1: indexig input folders (dicom) - abort function - user edit needed
render_asci_art("asci/prepare_dcm2niix.txt")
mapping_dicoms(variables_environment$directories$needed$dicom)

diagnostics$dcm2nii_conversion_paths = dcm2nii_wrapper(
  input = diagnostics$dcm2nii_paths$dicom_folder,
  output = diagnostics$dcm2nii_paths$nii_temp,
  scanner_type = variables_user$LUT$study_info$scanner_manufacturer
)

# dcm2niix conversion -----------------------------------------------------
render_asci_art("asci/convert_with_dcm2niix.txt")
dcm2nii_converter(diagnostics$dcm2nii_conversion_paths$nii,
                  diagnostics$dcm2nii_paths$nii_temp)

# json with sensitive information
dcm2nii_converter(diagnostics$dcm2nii_conversion_paths$json,  
                  str_replace(diagnostics$dcm2nii_paths$nii_temp,variables_environment$directories$needed$nii,  variables_environment$directories$needed$json_sensitive)
)



# json path indexing and extraction ---------------------------------------
render_asci_art("asci/JSON_extractor.txt")
extract_json_metadata(variables_environment$directories$needed$json_sensitive)
diagnostics$json_data <- read_metadata()


# sequence extraction  ----------------------------------------------------
render_asci_art("asci/LUT_sequences.txt")
variables_user$LUT$sequences <- synchronise_lut_sequence(variables_environment$files$lut$lut_sequences)

print.data.frame(variables_user$LUT$sequences)
# BIDS path creation
render_asci_art("asci/sequence2BIDS.txt")
diagnostics$json_data <- apply_lut_sequence(diagnostics$json_data)


# Copy2BIDS ---------------------------------------------------------------
render_asci_art("asci/copy2BIDS.txt")
copy2BIDS(variables_environment$files$diagnostic$nii2BIDS_paths)

# add BIDS metadata
add_BIDS_metadata()
render_asci_art("asci/success.txt")



