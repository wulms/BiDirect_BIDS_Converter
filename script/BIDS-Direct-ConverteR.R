# BIDS-Direct-ConverteR

## general setup
source("functions/functions.R")

setwd(working_dir)
## Create directories for outputs
lapply(directories, dir.create, recursive = TRUE, showWarnings = FALSE)

# Create templates
write_csv(session_variables, "user_settings/example_session.csv")
write_csv(as.data.frame(template_variables), "user_settings/example_study_info.csv")


## Stop 1: indexig input folders - abort function - user edit needed
dicoms_mapping <- list_dicom_folders("DICOM")


### read user settings file with the patterns for subjects, group and strings to remove

### apply these settings and check for inplausible patterns

directories_DICOM2 <- clean_foldernames(template_variables$remove_pattern_regex)



## dicom2niix - dependent on user_settings/



## json indexing



## json wrangling


##Stop 2: diagnostic outputs, user input check, is renaming plausible? What to you want to apply?


## Dashboard - check for "do.txt" - dependent on user_settings/



## nii_temp2BIDS - check for "do.txt"


## Export2Cooperate - check for other .txt file than "export_template.txt"

setwd("/home/niklas/Coding/GITHUB-BiDirect_BIDS_Converter/")
