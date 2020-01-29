# create environment variables

working_dir <- "/home/niklas/BIDS_test"
dcm2niix_path <- "/home/niklas/Downloads/"

print(paste0("Setup of working directory: ", working_dir))
print(paste0("dcm2niix is located at: ", dcm2niix_path))


# Variable settings -------------------------------------------------------

print("Setup of variables: ")

directories <- list(
  # input folder
  "dicom" = "dicom",
  # temporary output folders
  "nii_deidentifiable" = "nii_temp/deidentifiable",
  "nii_identifiable_headers" = "nii_temp/identifibale_headers",
  # final bids folder
  "bids" = "bids/sourcedata",
  # "bids_export" = "bids/export/sourcedata",
  # "bids_anonymized" = "bids/anonymized",
  # "bids_templates" = "user_information/BIDS_templates",
  "metadata" = "metadata",json
  # User interaction and information folders
  "user_diagnostics" = "user/diagnostics",
  "user_settings" = "user/settings",
   "dashboards" = "user/dashboards"
)
print(unlist(directories))

files <- list(
  # General BIDS files
  "bids_changes_txt" = paste0(directories$bids, "/CHANGES.txt"),
  "bids_dataset_json" = paste0(directories$bids, "/dataset_description.json"),
  "bids_readme_txt" = paste0(directories$bids, "/README.txt"),
  # LUT files for toolbox
  "example_lut_study_info" = paste0(directories$user_settings, "/example_lut_study_info.csv"),
  "example_lut_session"= paste0(directories$user_settings, "/example_lut_session.csv"),
  "lut_sessions" = paste0(directories$user_settings, "/lut_sessions.csv"),
  "lut_sequences" = paste0(directories$user_settings, "/lut_sequences.csv"),
  "lut_study_info" = paste0(directories$user_settings, "/lut_study_info.csv"),
  # Extracted json metadata
  "metadata" = paste0(directories$metadata, "/json_metadata.csv"),
  # Diagnostic debugging output
  "diagnostic_dcm2niix_paths" = paste0(directories$user_diagnostics, "/step1_dcm2nii_paths.html"),
  "diagnostic_nii2BIDS_paths" = paste0(directories$user_diagnostics, "/step2_nii_2_BIDS_paths.html"),
  # Dashboards for internal and external use
  "dashboard_internal_use" = paste0(directories$dashboards, "/dashboard_internal_use.html"),
  "dashboard_external_use" = paste0(directories$dashboards, "/dashboard_external_use.html") 
)
print(unlist(files))
# template variables

template_variables <- list(
  "study_name" = "BiDirect",
  "scanner_manufacturer" = "Philips",
  "subject_id_regex" = "^[:digit:]{5}$",
  "group_id_regex" = "[digit:]{1}(<=?[:digit:]{4}",
  "remove_pattern_regex" = "((b|d)i(d|b)i|bid|bd|bdi)(ect|rect)($|(rs|T2TSE|inclDIRSequenz|neu|abbruch))")
print(unlist(template_variables))

template_session_variables <- tibble(
  session_id = c("Baseline", "FollowUp", "FollowUp2", "FollowUp3"),
  session_id_BIDS = c("0", "2", "4", "6"),
  stringsAsFactors = FALSE
)
print(session_variables)

template_strings <- list(
  "session" = "Please code session to BIDS-nomenclature (e.g. Baseline/FollowUp1 to 0/1 or s0/s1) - the 'ses-' is added by the script",
  "sequence" = "Example: BIDS Sequence name: T1w, acq-highres_T1w, T2w, T2star, FLAIR, dwi, task-taskstring_bold, task-rest_acq-short_bold, task-rest_acq-long_bold")
print(template_strings)

bids_variables <- list(
  
)

