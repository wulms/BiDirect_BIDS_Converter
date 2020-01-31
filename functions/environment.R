# create environment variables


# Variable settings -------------------------------------------------------

print("Setup of variables: ")


variables_environment <- list(
  directories = list(
    setup = list("working_dir" = "/home/niklas/BIDS_test/",
                 "dcm2niix_path" = "/home/niklas/Downloads/"),
    needed = list(
      # input folder
      "dicom" = "dicom",
      # temporary output folders
      "nii" = "nii_temp/nii",
      "json_sensitive" = "nii_temp/json_sensitive",
      # final bids folder
      "bids" = "bids/sourcedata",
      # "bids_anonymized" = "bids/anonymized",
      "bids_templates" = "user_information/BIDS_templates",
      # User interaction and information folders
      "user_diagnostics" = "user/diagnostics",
      "user_settings" = "user/settings"
    ),
    optional = list("bids_export" = "bids/export/sourcedata",
                    "dashboards" = "user/dashboards")
  ),
  #print(unlist(files))
  # template variables
  
  templates = list(
    variables = list(
      "study_name" = "Your study",
      "method" = "MRI",
      # only MRI support (EEG/MEG) maybe later
      "scanner_manufacturer" = "Philips",
      # only Philips support (Siemens/GE later)
      "subject_id_regex" = "^[:digit:]{5}$",
      "group_id_regex" = "[digit:]{1}(<=?[:digit:]{4}",
      "remove_pattern_regex" = "((b|d)i(d|b)i|bid|bd|bdi)(ect|rect)($|(rs|T2TSE|inclDIRSequenz|neu|abbruch))"
    ),
    session_variables = tibble(
      session_id = c("Baseline", "FollowUp", "FollowUp2", "FollowUp3"),
      session_id_BIDS = c("0", "2", "4", "6")
    ),
    strings = list("session" = "Please code session to BIDS-nomenclature (e.g. Baseline/FollowUp1 to 0/1 or s0/s1) - the 'ses-' is added by the script",
                   "sequence" = "Example: BIDS Sequence name: T1w, acq-highres_T1w, T2w, T2star, FLAIR, dwi, task-taskstring_bold, task-rest_acq-short_bold, task-rest_acq-long_bold")
  )
)


variables_environment$files = list(
  # General BIDS files
  bids = list(
  "bids_changes_txt" = paste0(
    variables_environment$directories$needed$bids,
    "/CHANGES.txt"
  ),
  "bids_dataset_json" = paste0(
    variables_environment$directories$needed$bids,
    "/dataset_description.json"
  ),
  "bids_readme_txt" = paste0(
    variables_environment$directories$needed$bids,
    "/README.txt"
  )),
  lut = list(
  # LUT files for toolbox
  "example_lut_study_info" = paste0(
    variables_environment$directories$needed$user_settings,
    "/example_lut_study_info.csv"
  ),
  "example_lut_session" = paste0(
    variables_environment$directories$needed$user_settings,
    "/example_lut_session.csv"
  ),
  "lut_sessions" = paste0(
    variables_environment$directories$needed$user_settings,
    "/lut_sessions.csv"
  ),
  "lut_sequences" = paste0(
    variables_environment$directories$needed$user_settings,
    "/lut_sequences.csv"
  ),
  "lut_study_info" = paste0(
    variables_environment$directories$needed$user_settings,
    "/lut_study_info.csv"
  )),
  # Extracted json metadata
  diagnostic = list(
  # Diagnostic debugging output
  "dcm2niix_paths" = paste0(
    variables_environment$directories$needed$user_diagnostics,
    "/step1_dcm2nii_paths.html"
  ),
  "nii2BIDS_paths" = paste0(
    variables_environment$directories$needed$user_diagnostics,
    "/step2_nii_2_BIDS_paths.html"
  ),
  "metadata" = paste0(
    variables_environment$directories$needed$user_diagnostics,
    "/step3_json_extracted_metadata.csv"
  )),
  dashboards = list(
  # Dashboards for internal and external use
  "internal_use" = paste0(
    variables_environment$directories$optional$dashboards,
    "/dashboard_internal_use.html"
  ),
  "external_use" = paste0(
    variables_environment$directories$optional$dashboards,
    "/dashboard_external_use.html"
  ))
)

print(variables_environment)
