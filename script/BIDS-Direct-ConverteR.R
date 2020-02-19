# BIDS-Direct-ConverteR
#setwd("/home/niklas/Coding/GITHUB-BiDirect_BIDS_Converter/")


# args = "/mnt/TB8Drive/bidirect2bids/"

## general setup
source("functions/functions.R")

render_asci_art("asci/logo.txt")

# pre-installation step
install_dcm2niix()

## settings
variables_environment$directories$setup$working_dir <- file.path(args)
 
# Create templates
create_templates()
#cat(getwd())

## Stop 1: indexig input folders (dicom) - abort function - user edit needed
render_asci_art("asci/prepare_dcm2niix.txt")
mapping_dicoms(variables_environment$directories$needed$dicom)
#cat(getwd())

diagnostics$dcm2nii_conversion_paths = dcm2nii_wrapper(
  input = diagnostics$dcm2nii_paths$dicom_folder,
  output = diagnostics$dcm2nii_paths$nii_temp,
  scanner_type = variables_user$LUT$study_info$scanner_manufacturer
)
#cat(getwd())

# dcm2niix conversion -----------------------------------------------------
render_asci_art("asci/convert_with_dcm2niix.txt")
dcm2nii_converter(diagnostics$dcm2nii_conversion_paths$nii,
                  diagnostics$dcm2nii_paths$nii_temp)
#cat(getwd())

# json with sensitive information
dcm2nii_converter(diagnostics$dcm2nii_conversion_paths$json,  
                  str_replace(diagnostics$dcm2nii_paths$nii_temp,variables_environment$directories$needed$nii,  variables_environment$directories$needed$json_sensitive)
)
#cat(getwd())



# json path indexing and extraction ---------------------------------------
render_asci_art("asci/JSON_extractor.txt")
extract_json_metadata(variables_environment$directories$needed$json_sensitive)
diagnostics$json_data <- read_metadata()
#cat(getwd())


# sequence extraction  ----------------------------------------------------
render_asci_art("asci/LUT_sequences.txt")
variables_user$LUT$sequences <- synchronise_lut_sequence(variables_environment$files$lut$lut_sequences)
#cat(getwd())

# BIDS path creation
render_asci_art("asci/sequence2BIDS.txt")
diagnostics$json_data <- apply_lut_sequence(diagnostics$json_data)
#cat(getwd())


# Copy2BIDS ---------------------------------------------------------------
render_asci_art("asci/copy2BIDS.txt")
copy2BIDS(variables_environment$files$diagnostic$nii2BIDS_paths)
#cat(getwd())

# add BIDS metadata
add_BIDS_metadata()
render_asci_art("asci/success.txt")
#cat(getwd())

# create Dashboard
# setwd(variables_environment$directories$setup$repo_dir)
path_to_folder(variables_environment$files$dashboards$internal_use)
rmarkdown::render(variables_environment$files$dashboards$internal_rmd, 
                  # output_file = variables_environment$files$dashboards$internal_use,
                  output_dir = paste0(variables_environment$directories$setup$working_dir , "bids/"),
                  params=list(study=variables_user$LUT$study_info$study_name,
                              df=diagnostics$json_data,
                              wd=paste0(variables_environment$directories$setup$working_dir , "bids/"),
                              pattern_to_remove=variables_user$LUT$study_info$remove_pattern_regex))

 # setwd(variables_environment$directories$setup$repo_dir)

  

                                        