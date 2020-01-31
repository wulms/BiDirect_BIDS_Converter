# BIDS-Direct-ConverteR

setwd("/home/niklas/Coding/GITHUB-BiDirect_BIDS_Converter//")

print("Welcome to the BIDS-Direct-ConverteR")
Sys.sleep(3)
## general setup
source("functions/functions.R")


## Create directories for outputs
# lapply(directories,
#        dir.create,
#        recursive = TRUE,
#        showWarnings = FALSE)

# Create templates

create_templates()

## Stop 1: indexig input folders - abort function - user edit needed
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













# old ---------------------------------------------------------------------



## Create and update 'session_info.csv' with new session foldernames
if (file.exists("user_settings/session_info.csv")) {
  print("File 'session_info.csv' exists. Reading file.")
  user_session_info <-
    read_csv("user_settings/session_info.csv") %>% data.frame()
  user_sessions <-
    user_session_info %>% select(your_session_id) %>% unique() %>% mutate(session_BIDS = "0/1/2/3")
  dicom_sessions <-
    dicoms_mapping %>% select(your_session_id) %>% unique() %>% mutate(session_BIDS = "0/1/2/3")
  dicoms_new <- anti_join(dicom_sessions, user_sessions)
  if (nrow(dicoms_new) > 0) {
    print(
      paste0(
        "New session-id was identified. This is the total number of new entries to the 'session_info.csv': ",
        nrow(dicoms_new),
        " with the new session-id: ",
        paste0(
          dicoms_mapping$your_session_id,
          sep = " ",
          collapse = " "
        )
      )
    )
    write_csv(dicoms_new, "user_settings/session_info.csv", append = TRUE)
  } else {
    print(
      paste0(
        "No new session-ids were found. Check that your BIDS-session-ids are valid: ",
        paste0(
          user_session_info$session_BIDS,
          sep = " ",
          collapse = " "
        )
      )
    )
  }
} else {
  print(
    "The file 'user_settings/session_info.csv' does not exist. Create file. Please edit the session information manually."
  )
  write_csv(
    dicoms_mapping %>% select(your_session_id) %>% unique() %>% mutate(session_BIDS = "0/1/2/3"),
    "user_settings/session_info.csv"
  )
  print("The script stops here, so that you can edit the 'session_info.csv'.")
  exit()
}

## Check for all edits on session_info.csv
print("Checking for not edited session-ids in 'session_info.csv'")
if (sum(str_detect(user_session_info$session_BIDS, "0/1/2/3")) != 0) {
  print("Please edit file 'session_info.csv'. One sequence seems to be not edited")
  print(user_session_info %>% filter(str_detect(session_BIDS, "0/1/2/3") == 1))
  exit()
} else {
  print("Session names in 'session_info.csv' are edited. Please check, if naming is valid")
  print(user_study_info)
}

### read user settings file with the patterns for subjects, group and strings to remove
print("Loading 'study_info.csv'")
user_study_info <- read_csv("user_settings/study_info.csv")
print(user_study_info)

### apply these settings and check for inplausible patterns
print(
  paste0(
    "Cleaning the foldernames using your regular expressions for the patterns: ",
    user_study_info$remove_pattern_regex
  )
)
directories_DICOM2NII_temp <-
  clean_foldernames(user_study_info$remove_pattern_regex)
print(
  paste0(
    "Selecting subjects that do not fit the subject regular expression: ",
    user_study_info$subject_id_regex
  )
)

not_removed <-
  str_remove(directories_DICOM2NII_temp$subjects_BIDS,
             user_study_info$subject_id_regex) %>% unique()
if (length(not_removed) > 1) {
  print(
    paste0(
      "Identified non fitting patterns of the subject names when applying your regular expression for the subjects :",
      not_removed
    )
  )
  print(
    "Exits code - please edit the regular expressions for subjects and the patterns you want to remove."
  )
  exit()
} else {
  print(
    "Your 'subject regex' worked after your 'patterns to remove' have cleaned all subject names for BIDS. Please check plausibility."
  )
  print(directories_DICOM2NII_temp)
  print(
    "Exported information into 'user_information/1_dcm2niix_paths.csv', please check diagnostic output."
  )
  write_csv(directories_DICOM2NII_temp,
            "user_information/1_dcm2niix_paths.csv")
}


## dicom2niix - dependent on user_settings/
dcm2niix_anonymized(directories_DICOM2NII_temp$dicom_folder,
                    directories_DICOM2NII_temp$nii_temp)

directories_DICOM2NII_temp$nii_headers <-
  str_replace(directories_DICOM2NII_temp$nii_temp,
              "NII_temp",
              "NII_headers")

dcm2niix_header_extraction(directories_DICOM2NII_temp$dicom_folder,
                           directories_DICOM2NII_temp$nii_headers)


## json indexing
json_files <- index_jsons(directories$NII_headers_dir) %>%
  data.frame(json_files = ., stringsAsFactors = FALSE)  %>%
  mutate(
    your_session_id = str_split(json_files, "/", simplify = TRUE)[, 2],
    your_subject_id = str_split(json_files, "/", simplify = TRUE)[, 3],
    your_sequence_id = str_split(json_files, "/", simplify = TRUE)[, 4] %>% str_remove(".json")
  )

sequences_unique <- json_files %>%
  select(your_sequence_id) %>%
  unique()

if (file.exists("user_settings/sequence_info.csv") == 1) {
  print("Reading in existing 'user_settings/sequence_info.csv'.")
  sequences_existing <- read_csv("user_settings/sequence_info.csv")
  sequences_new <-
    anti_join(sequences_existing, sequences_unique) %>%
    mutate(sequence_id_BIDS = "examples: T1w, acq-highres_T1w, T2w, T2star, FLAIR, dwi, task-taskstring_bold, task-rest_acq-short_bold, task-rest-long_bold",
           relevant = "please code binary 1 = keep, 0 = ignore")
  
  if (nrow(sequences_new) > 0) {
    print(paste0(
      "Found ",
      nrow(sequences_new),
      " new files. Will be appended. Please edit these."
    ))
    print(
      "Planned stop: New sequence added. Please edit sequence to BIDS and decide on relevance."
    )
    exit()
  } else {
    print("No new sequences found. Everything seems plausible.")
  }
  write_csv(sequences_new, "user_settings/sequence_info.csv", append = TRUE)
} else {
  print(
    "File 'user_settings/sequence_info.csv' does not exist. Will be created. Please rename the identified sequences to BIDS standard and select the relevant sequences."
  )
  sequences_unique %>%
    mutate(sequence_id_BIDS = "examples: T1w, acq-highres_T1w, T2w, T2star, FLAIR, dwi, task-taskstring_bold, task-rest_acq-short_bold, task-rest-long_bold",
           relevant = "please code binary 1 = keep, 0 = ignore") %>%
    write_csv("user_settings/sequence_info.csv")
  print(sequences_unique)
  exit()
}


## json wrangling

print("Starting json2bids renaming. Read 'user_settings/sequence_info.csv'")
user_sequence_info <- read_csv("user_settings/sequence_info.csv")
relevant_sequences <-
  user_sequence_info %>% select(sequence_id_BIDS, relevant) %>% unique()
difference_check_jsons(json_metadata, "json_files.csv")

## json headers need extraction every time - one sequence with another attribute can crash the whole table
df_json_headers <- get_json_headers(json_files$json_files)
read_json_headers(json_files$json_files, df_json_headers)



json_metadata <- read_csv("json_files.csv") %>%
  mutate(
    json_files = Path,
    your_session_id = str_split(json_files, "/", simplify = TRUE)[, 2],
    your_subject_id = str_split(json_files, "/", simplify = TRUE)[, 3],
    your_sequence_id = str_split(json_files, "/", simplify = TRUE)[, 4] %>% str_remove(".json")
  ) %>%
  mutate(
    subject_id_BIDS = your_subject_id %>% str_remove_all("[:punct:]{1}|[:blank:]{1}") %>%
      str_remove_all(regex("plus", ignore_case = TRUE)) %>%
      str_remove_all(
        regex(user_study_info$remove_pattern_regex, ignore_case = TRUE)
      ) %>%
      str_remove("10738BiDirecteigentlich"),
    group_BIDS = str_extract(subject_id_BIDS, user_study_info$group_id_regex),
    session_id_BIDS = stri_replace_all_regex(
      your_session_id,
      user_session_info$your_session_id,
      user_session_info$session_BIDS,
      vectorize_all = FALSE
    ),
    sequence_id_BIDS = stri_replace_all_regex(
      your_sequence_id,
      paste0("^", user_sequence_info$your_sequence_id, "$"),
      user_sequence_info$sequence_id_BIDS,
      vectorize_all = FALSE
    ),
    path_BIDS = paste0(
      directories$BIDS_dir,
      "/",
      subject_id_BIDS,
      "/",
      session_id_BIDS,
      "/sub-",
      subject_id_BIDS,
      "_ses-",
      session_id_BIDS,
      "_",
      sequence_id_BIDS
    )
  ) %>%
  left_join(relevant_sequences, by = "sequence_id_BIDS")

##Stop 2: diagnostic outputs, user input check, is renaming plausible? What to you want to apply?

diag_double_sequences <- relevant_sequences %>%
  group_by(sequence_id_BIDS) %>%
  count() %>% filter(n > 1)

diag_implausible_settings <- json_metadata %>%
  filter(
    !(relevant %in% c(0, 1)) |
      !(sequence_id_BIDS %in% user_sequence_info$sequence_id_BIDS) |
      !(session_id_BIDS %in% user_session_info$session_BIDS) |
      str_detect(subject_id_BIDS, user_study_info$subject_id_regex) == 0
  )

diag_duplicates <- json_metadata %>%
  select(subject_id_BIDS, session_id_BIDS, sequence_id_BIDS) %>%
  group_by_all() %>%
  count() %>%
  filter(n > 1)

diag_duplicate_paths <- json_metadata %>%
  select(path_BIDS) %>%
  group_by_all() %>%
  count() %>% filter(n > 1)

## Dashboard - check for "do.txt" - dependent on user_settings/



## nii_temp2BIDS - check for "do.txt"


## Export2Cooperate - check for other .txt file than "export_template.txt"

setwd("/home/niklas/Coding/GITHUB-BiDirect_BIDS_Converter//")







