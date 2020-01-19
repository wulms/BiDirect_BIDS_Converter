# functions

## create environment variables

working_dir <- "/home/niklas/BIDS_test"
setwd(working_dir)
directories <- list("NII_temp_dir"= "NII_temp",
     "NII_headers_dir" = "NII_headers",
     "BIDS_dir" = "BIDS/sourcedata",
     "BIDS_export" = "BIDS/export",
     "user_information" = "user_information",
     "user_settings" = "user_settings",
     "Dashboards" = "Dashboards")

lapply(directories, dir.create, recursive = TRUE, showWarnings = FALSE)

## template variables

template_variables <- list(
  "study_name" = "BiDirect",
  "scanner_manufacturer" = "Philips",
  "session_id" = c("Baseline","FollowUp1", "FollowUp2", "FollowUp3"),
  "subject_id_regex" = "[:digit:]{5}",
  "group_id_regex" = "[digit:]{1}(<=?[:digit:]{4}",
  "remove_pattern_regex" = ",BiDirect")

template_strings <- list(
  ""
)
# 1st level - Dicom2NII

## get dicom folders


## find_jsons