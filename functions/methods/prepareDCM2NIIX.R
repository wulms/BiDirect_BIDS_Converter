# dcm2niix output path creation -------------------------------------------



#' Finds dicom folders in dicom/session/subject folder structure
#'
#' @param input_folder a folder, containing /session/subject/dicomdata structure 
#'
#' @return dataframe containing list, session and subject id
#' @examples list_dicom_folders("dicom")
list_dicom_folders <- function(input_folder) {
  df <- dir(input_folder, full.names = TRUE) %>%
    lapply(FUN = dir,
           recursive = FALSE,
           full.names = TRUE) %>%
    unlist() %>%
    data.frame(dicom_folder = ., stringsAsFactors = FALSE)  %>%
    mutate(
      your_session_id = str_split(dicom_folder, "/", simplify = TRUE)[, 2],
      your_subject_id = str_split(dicom_folder, "/", simplify = TRUE)[, 3]
    )
  return(df)
}


#' Check for session plausibility (no NA, punctuation or blanks allowed!)
#'
#' @param input list, containing session-ids
check_session_plausibility <- function(input) {
  if (any(str_detect(input, "more"),na.rm = TRUE)) {stop("Found a row, that was not edited (still contains 'more') in the lut_sessions.csv. Please edit the file again.")}
  else if (any(is.na(input))) {stop("Found a row, that is empty in the lut_sessions.csv. Please edit the file again.") }
  else if (any(str_detect(input, "[:punct:]"))) {stop("Found a row, that contains punctuation. Please use only alphanumeric signs.")}
  else if (any(str_detect(input, "[:blank:]"))) {stop("Found a row, that contains a blank. Please use only alphanumeric signs.")}
  else {print("Your lut_sessions.csv looks fine.")}
}


#' Title
#'
#' @param df 
#' @param lut_session 
#' @param subject_regex 
#' @param group_regex 
#' @param pattern_remove 
#' @param output 
#'
#' @return
#' @export
#'
#' @examples
clean_foldernames <- function(df, 
                              lut_session = variables_user$LUT$session,
                              subject_regex = variables_user$LUT$study_info$subject_id_regex,
                              group_regex = variables_user$LUT$study_info$group_id_regex,
                              pattern_remove = variables_user$LUT$study_info$remove_pattern_regex,
                              output = variables_environment$directories$needed$nii) {
  df <- df %>%
    mutate(
      subjects_BIDS = your_subject_id %>%
        str_remove_all(regex(pattern_remove, ignore_case = TRUE)),
      group_BIDS = str_extract(subjects_BIDS, regex(group_regex)),
      session_BIDS = stri_replace_all_regex(your_session_id, paste0("^",lut_session$session_id,"$"), lut_session$session_id_BIDS, vectorize_all = FALSE),
      nii_temp = paste0(output, "/ses-", session_BIDS, "/sub-", subjects_BIDS),
      not_removed = str_remove(subjects_BIDS, subject_regex) %>% str_remove(pattern_remove)
      )
  return(df)
}

#' Checks subjects nomenclature. Are there subject-ids that do not match the subject regex?
#'
#' @param subjects_BIDS subject-ids
#' @param subject_regex subject-regex 
#' @examples
check_subject_nomenclature <- function(subjects_BIDS, subject_regex) {
  dir.create(variables_environment$directories$needed$user_diagnostics, showWarnings = FALSE, recursive = TRUE)
  if (any(str_detect(subjects_BIDS, paste0("^", subject_regex, "$"), negate = TRUE))) {
    write_csv(diagnostics$dcm2nii_paths, variables_environment$files$diagnostic$dcm2niix_paths)
    cat("\n\n")
    print(paste("Implausible subjects_BIDS found - look into file: ", variables_environment$files$diagnostic$dcm2niix_paths))
    print(paste("Your subject-regex:", paste0("^", subject_regex, "$")))
    print(paste("Your pattern-regex:", variables_user$LUT$study_info$remove_pattern_regex))
    cat("\n\n")
    diagnostics$dcm2nii_paths %>%
      select(your_subject_id, subjects_BIDS, group_BIDS, nii_temp, not_removed) %>%
      filter(str_detect(subjects_BIDS, paste0("^", subject_regex, "$")) == 0) %>%
      print.data.frame()
    render_asci_art("asci/error_study_info.txt")
    stop("Code breaks here: Implausible subjects_BIDS id found - please edit lut_study_info to edit your regex and the patterns to remove. Then start again.")
  } else {print(paste("Filename cleaning done, subjects_BIDS pattern recognized. Diagnostic output: ", variables_environment$files$diagnostic$dcm2niix_paths))
    print.data.frame(diagnostics$dcm2nii_paths)
    write_csv(diagnostics$dcm2nii_paths, variables_environment$files$diagnostic$dcm2niix_paths)
  }
}


#' Finds unqiue session-ids and adds them to the lut_session.csv
#'
#' @param dicom_folder 
#'
#' @return Appends the identified session-ids to the lut_session.csv
mapping_dicoms <- function(dicom_folder) {
  dicoms_mapping <<- list_dicom_folders(dicom_folder)
  variables_user$folder$dicoms <<- dicoms_mapping
  print("These files were found.")
  print.data.frame(dicoms_mapping)
  cat("\n\n")
  # Session ID unique readout
  unique_variables <-
    tibble(session_id = unique(dicoms_mapping$your_session_id),
            session_id_BIDS = "1/2/.../4 or more?")

  # Session ID update, plausibility check and readout
  cat("\n\n")
  if (file.exists(variables_environment$files$lut$lut_sessions) == 0) {
    print(paste0("The file '", variables_environment$files$lut$lut_sessions, "' was not found. Creating this file and a template with prefix 'example_'."))
    # write_csv(variables_environment$templates$session_variables, variables_environment$files$lut$example_lut_session)
    write_csv(unique_variables, variables_environment$files$lut$lut_sessions)
    render_asci_art("asci/error_session.txt")
    stop("Script aborts here: Please edit the lut_session_file and restart!")
  } else {
    print(paste0("The file '", variables_environment$files$lut$lut_sessions, "' exists. Importing information"))
    variables_user$LUT$session <<-  read_csv(variables_environment$files$lut$lut_sessions)
    print("This is your session input: ")
    print.data.frame(variables_user$LUT$session)
    cat("\n\n")
    check_session_plausibility(variables_user$LUT$session$session_id_BIDS)
    cat("\n\n")
    print("Comparing for new sessions")
    unique_variables <- unique_variables %>%
      filter(!(session_id %in% variables_user$LUT$session$session_id))
    if(nrow(unique_variables) == 1) {
      print("New session-id identified. Appended to lut-session.csv")
      print.data.frame(unique_variables)
      write_csv(unique_variables, variables_environment$files$lut$lut_sessions, append = TRUE)
      render_asci_art("asci/error_session.txt")
      stop("Script aborts - New session-id added. Please edit the lut_session.csv file. Then start script again.")
    }
  

# Subject ID cleaning
  cat("\n\n")
  
  print("Subject-id detection, cleaning and plausibility check")
  Sys.sleep(2)
  
  diagnostics <<- list(dcm2nii_paths = clean_foldernames(df = dicoms_mapping))
 
  print.data.frame(variables_user$LUT$study_info)
   # Checking for implausible subject names
  check_subject_nomenclature(
    subjects_BIDS = diagnostics$dcm2nii_paths$subjects_BIDS,
    subject_regex = variables_user$LUT$study_info$subject_id_regex
  )
  print("=============================================================")
  print("Congratulations: The dcm2bids-preparation was successfull!")
  }
}
  
  
  