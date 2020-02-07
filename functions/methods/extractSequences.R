# sequence extraction and comparison --------------------------------------



#' Title
#'
#' @param df 
#'
#' @return
#' @export
#'
#' @examples
extract_sequences <- function(df){
  sequences <- df %>%
    select(sequence, ProtocolName, SeriesDescription) %>% unique() 
  return(sequences)
}

#' Title
#'
#' @param df 
#'
#' @return
#' @export
#'
#' @examples
mutate_sequence <- function(df){
  df <- df %>%
    mutate(BIDS_sequence_ID = "bids_sequence",
           type = "anat/dwi/func",
           relevant = "0/1")
  return(df)
}

#' Title
#'
#' @param df 
#'
#' @return
#' @export
#'
#' @examples
check_sequence_plausibility <- function(df){
  if(any(is.na(df$BIDS_sequence_ID)) | any(str_detect(df$BIDS_sequence_ID, "bids_sequence"))) {
    render_asci_art("asci/error_sequences.txt")
    stop("Planned error: empty or unedited 'BIDS_sequence_ID' column. Please edit 'BIDS_sequence_ID' in lut_sequences.csv")
  } else if (any(is.na(df$type)) | any(str_detect(df$type, "anat/dwi/func"))) {
    render_asci_art("asci/error_sequences.txt")
    stop("Error: empty or unedited 'type' column. Please edit 'type' in lut_sequences.csv")
  } else if (any(is.na(df$relevant)) | any(str_detect(df$type, "0/1"))){
    render_asci_art("asci/error_sequences.txt")
    stop("Error: empty or unedited 'relevant' column. Please edit 'relevant' in lut_sequences.csv")
  } 
}

#' Title
#'
#' @param filename 
#'
#' @return
#' @export
#'
#' @examples
synchronise_lut_sequence <- function(filename){
  setwd(variables_environment$directories$setup$working_dir)
  sequences <- extract_sequences(diagnostics$json_data)
  cat("\n\n")
  
  if(file.exists(filename) == 0){
    print("File lut_sequences.csv does not exist. Creates file.")
    sequences_df <- mutate_sequence(sequences)
    print.data.frame(sequences_df)
    write_csv(sequences_df,
              filename)
    render_asci_art("asci/error_sequences.txt")
    stop("lut_sequences.csv was updated. Please edit the BIDS_sequence_ID, type and relevant column and restart the script.")
  } else {
    print("File exists - update possible")
    cat("\n\n")
    print.data.frame(read_csv(filename))
    sequences_old <<- read_csv(filename) %>% select(sequence, ProtocolName, SeriesDescription)
    sequences_df <- anti_join(sequences, sequences_old, by = "sequence") 
    # print(sequences)
    print("Already edited sequences: ")

    cat("\n\n")
    if(nrow(sequences_df) > 0){
      cat("\n\n")
      print("New sequences: ")
      cat("\n\n")
      print.data.frame(sequences_df)
      cat("\n\n")
      #variables_user$LUT$sequences
      sequences_df <- sequences_df %>% mutate_sequence()
      write_csv(sequences_df, filename, append = TRUE)
      render_asci_art("asci/error_sequences.txt")
      stop("lut_sequences.csv was updated. Please edit the BIDS_sequence_ID, type and relevant column and restart the script.")
    } else if(nrow(sequences_df) == 0){
      print("No new sequences identified. Loading the lut_sequences.csv")
      sequences_df <- read_csv(filename)
      check_sequence_plausibility(sequences_df)
      sequences_df <- sequences_df %>% select(sequence, BIDS_sequence_ID, type, relevant) %>% distinct()
      return(sequences_df)
    }
  }
}

#' Title
#'
#' @param df 
#'
#' @return
#' @export
#'
#' @examples
apply_lut_sequence <- function(df){
  print.data.frame(variables_user$LUT$sequences)
  df <- df %>% 
    left_join(variables_user$LUT$sequences) %>% 
    mutate(group_BIDS = str_extract(subject, regex(variables_user$LUT$study_info$group_id_regex)),
           sequence_BIDS = stri_replace_all_regex(sequence, paste0("^",variables_user$LUT$sequences$sequence, "$"), variables_user$LUT$sequences$BIDS_sequence_ID, vectorize_all = FALSE),
      BIDS_json = paste0(variables_environment$directories$needed$bids,
        "/", subject,
        "/", session,
        "/", type,
        "/", subject,
        "_", session,
        "_", sequence_BIDS, ".json"
      )) 
  df_diagnostic_sequence_mapping <- df %>% select(subject, session, sequence, type, input_json, BIDS_json, relevant) 
  
  cat("\n\n This is your mapping2BIDS \n\n")
  df_diagnostic_sequence_mapping %>% select(input_json, BIDS_json) %>%
    print.data.frame(right = FALSE)
  write_csv(df_diagnostic_sequence_mapping, variables_environment$files$diagnostic$nii2BIDS_paths)
  # Output of sensitive informaion df
  df_sensitive_info <- df %>% select(subject, session, group_BIDS, PatientID, PatientName, AcquisitionDateTime, PatientBirthDate, PatientSex, PatientWeight) %>%
    mutate(AcquisitionDateTime = as.Date(AcquisitionDateTime),
           Age = time_length(difftime(AcquisitionDateTime, PatientBirthDate), "years") %>% round(digits = 2)) %>%
    unique()
  cat("\n\n Extracted following sensitive information: \n\n")
  print.data.frame(df_sensitive_info)
  write_csv(df_sensitive_info, "user/diagnostics/sensitive_subject_information.csv")
  print("Sequence mapping was successful. Saved output to 'user/diagnostic/step2_nii_2_BIDS_paths.csv'. Please look for implausible sequences")
  return(df)
}