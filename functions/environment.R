# create environment variables

working_dir <- "/home/niklas/BIDS_test"
dcm2niix_path <- "/home/niklas/Downloads/"

directories <- list(
  "NII_temp_dir"= "NII_temp",
   "NII_headers_dir" = "NII_headers",
   "BIDS_dir" = "BIDS/sourcedata",
   "BIDS_export" = "BIDS/export",
   "user_information" = "user_information",
   "user_settings" = "user_settings",
   "Dashboards" = "Dashboards")

# template variables

session_variables <- data.frame(
  session_id = c("Baseline", "FollowUp", "FollowUp2", "FollowUp3"),
  session_id_BIDS = c("0", "1", "2", "3"),
  stringsAsFactors = FALSE
)

template_variables <- list(
  "study_name" = "BiDirect",
  "scanner_manufacturer" = "Philips",
  "subject_id_regex" = "^[:digit:]{5}$",
  "group_id_regex" = "[digit:]{1}(<=?[:digit:]{4}",
  "remove_pattern_regex" = "((b|d)i(d|b)i|bid|bd|bdi)(ect|rect)($|(rs|T2TSE|inclDIRSequenz|neu|abbruch))")

template_strings <- list(
  ""
)
