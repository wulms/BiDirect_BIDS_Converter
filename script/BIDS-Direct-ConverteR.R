# BIDS-Direct-ConverteR


print("Welcome to the BIDS-Direct-ConverteR")
## general setup
source("functions/functions.R")

setwd(working_dir)
## Create directories for outputs
lapply(directories, dir.create, recursive = TRUE, showWarnings = FALSE)

# Create templates
print("Creating files --------")
write_csv(session_variables, "user_settings/example_session.csv")
write_csv(as.data.frame(template_variables), "user_settings/example_study_info.csv")
write_csv(as.data.frame(template_variables), "user_settings/study_info.csv")
print("Please edit 'user_settings/study_info.csv' - the 'example_study_info.csv' is a template for editing.")

## Stop 1: indexig input folders - abort function - user edit needed
dicoms_mapping <- list_dicom_folders("DICOM")


## Create and update 'session_info.csv' with new session foldernames
if(file.exists("user_settings/session_info.csv")) {
  print("File 'session_info.csv' exists. Reading file.")
  user_session_info <- read_csv("user_settings/session_info.csv")
  user_sessions <- user_session_info %>% select(your_session_id) %>% unique() %>% mutate(session_BIDS = "0/1/2/3")
  dicom_sessions <- dicoms_mapping %>% select(your_session_id) %>% unique() %>% mutate(session_BIDS = "0/1/2/3")
  dicoms_new <- anti_join(dicom_sessions, user_sessions)
  if(nrow(dicoms_new) > 0) {
    print(paste0("New session-id was identified. This is the total number of new entries to the 'session_info.csv': ", nrow(dicoms_new), " with the new session-id: ", dicoms_mapping$your_session_id))
    write_csv(dicoms_new, "user_settings/session_info.csv", append = TRUE)
  } else {
    print("No new session-ids were found.")
  }
} else {
  print("The file 'user_settings/session_info.csv' does not exist. Create file. Please edit the session information manually.")
  write_csv(dicoms_mapping %>% select(your_session_id) %>% unique() %>% mutate(session_BIDS = "0/1/2/3"), "user_settings/session_info.csv")
  print("The script stops here, so that you can edit the 'session_info.csv'.")
  exit()
}

## Check for all edi
user_study_info <- read_csv("user_settings/study_info.csv")




if(sum(str_detect(user_session_info$session_BIDS, "0/1/2/3")) != 0) {
  print("Please edit file 'session_info.csv'. One sequence seems to be not edited")
  print(user_session_info %>% filter(str_detect(session_BIDS, "0/1/2/3") == 1))
} else {
    print("Session names in 'session_info.csv' are edited. Please check, if naming is valid")
  print(user_session_info)
  }

### read user settings file with the patterns for subjects, group and strings to remove

### apply these settings and check for inplausible patterns

directories_DICOM2 <- clean_foldernames(template_variables$remove_pattern_regex)



## dicom2niix - dependent on user_settings/



## json indexing
json_files <- index_jsons(directories$NII_headers_dir)


## json wrangling


##Stop 2: diagnostic outputs, user input check, is renaming plausible? What to you want to apply?


## Dashboard - check for "do.txt" - dependent on user_settings/



## nii_temp2BIDS - check for "do.txt"


## Export2Cooperate - check for other .txt file than "export_template.txt"

setwd("/home/niklas/Coding/GITHUB-BiDirect_BIDS_Converter/")
