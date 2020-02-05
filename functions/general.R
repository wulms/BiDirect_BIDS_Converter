# general functions - these are used at different points of the script

options(readr.num_columns = 0)
options(width = 320)

#' Create folders from (list of) filenames
#'
#' @param list_of_files filename or list of files
#'
#' @return Nothing - creates the files on the system
#' @export
#'
#' @examples
path_to_folder <- function(list_of_files) {
  paths_folder <- sub("[/][^/]+$", "", list_of_files)
  paths_folder <- unique(paths_folder)
  print(head(paths_folder))
  lapply(paths_folder,
         dir.create,
         recursive = TRUE,
         showWarnings = FALSE)
}

render_asci_art <- function(asci_file){
  asci <- readLines(paste0(variables_environment$directories$setup$repo_dir, "/", asci_file), warn=FALSE)
  # asci <- dput(asci)
  cat(asci, sep = "\n")
}

# Time measurement --------------------------------------------------------
list_items <- function(i, list, string) {
  cat("\014")
  print(string)
  print(paste(
    i,
    " / ",
    length(list),
    " total. (",
    round(i / length(list) * 100, 1),
    "%)"))
  print(paste(
    "list item:",
    list[i]
  ))
}

start_time <- function() {
  Sys.time()
}
measure_time <- function(i, list, start) {
  end <- Sys.time()
  time_difference <- difftime(end, start, unit = "mins") %>% round(2)
  print(paste(
    "Time since start: ",
    time_difference,
    " min.  ETA: ",
    (difftime(end, start, unit = "mins")/i*length(list) - time_difference) %>% round(2),
    " min. remaining."
  ))
}



# Preparation functions ---------------------------------------------------

create_templates <- function () {
  setwd(variables_environment$directories$setup$working_dir)
  if (file.exists(variables_environment$files$lut$lut_study_info) == 0) {
    print("Creating user folder")
    dir.create(
      variables_environment$directories$needed$user_settings,
      showWarnings = FALSE,
      recursive = TRUE
    )
    print("Creating template files --------")
    # Study info file <- user edit
    write_csv(
      as.data.frame(variables_environment$templates$variables),
      variables_environment$files$lut$lut_study_info
    )
    # Template file
    write_csv(
      as.data.frame(variables_environment$templates$variables),
      variables_environment$files$lut$example_lut_study_info
    )
    print(
      paste(
        "Please edit '",
        variables_environment$files$lut$lut_study_info,
        "' - the '",
        variables_environment$files$lut$example_lut_study_info,
        "' is a template for editing."
      )
    )
    stop("Script aborts: Please edit the file and restart the code.")
  } else {
    print(
      paste(
        "The template file:'",
        variables_environment$files$lut$lut_study_info,
        "' was found."
      )
    )
    # Global variable assignment here!
    variables_user <<- list(LUT = list(
      study_info = read_csv(variables_environment$files$lut$lut_study_info)
    ))
    print(variables_user$LUT$study_info)
    print("Please wait 4 seconds and take care, that these options are right")
    print("Next step: list dicom folders, and extract session information")
    # return(variables_user)
  }
}



# dcm2niix output path creation -------------------------------------------


mapping_dicoms <- function(dicom_folder) {
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
  dicoms_mapping <<-
    list_dicom_folders(dicom_folder)
  variables_user$folder$dicoms <<- dicoms_mapping
  print("These files were found.")
  print.data.frame(dicoms_mapping)
  cat("\n\n")
  Sys.sleep(2)
  # Session ID unique readout
  unique_variables <-
    tibble(
      session_id = unique(dicoms_mapping$your_session_id),
      session_id_BIDS = "1/2/.../4 or more?"
    )
  # print("Unique sessions identified:")
  # print(unique_variables)
  Sys.sleep(2)
  
  # Session ID update, plausibility check and readout
  check_session_plausibility <- function(input) {
    if (any(str_detect(input, "more"),na.rm = TRUE)) {stop("Found a row, that was not edited (still contains 'more') in the lut_sessions.csv. Please edit the file again.")}
    else if (any(is.na(input))) {stop("Found a row, that is empty in the lut_sessions.csv. Please edit the file again.") }
    else if (any(str_detect(input, "[:punct:]"))) {stop("Found a row, that contains punctuation. Please use only alphanumeric signs.")}
    else if (any(str_detect(input, "[:blank:]"))) {stop("Found a row, that contains a blank. Please use only alphanumeric signs.")}
    else {print("Your lut_sessions.csv looks fine.")}
  }
  cat("\n\n")
  if (file.exists(variables_environment$files$lut$lut_sessions) == 0) {
    print(
      paste0(
        "The file '",
        variables_environment$files$lut$lut_sessions,
        "' was not found. Creating this file and a template with prefix 'example_'."
      )
    )
    write_csv(
      variables_environment$templates$session_variables,
      variables_environment$files$lut$example_lut_session
    )
    write_csv(unique_variables,
              variables_environment$files$lut$lut_sessions)
    stop("Script aborts here: Please edit the lut_session_file and restart!")
  } else {
    print(
      paste0(
        "The file '",
        variables_environment$files$lut$lut_sessions,
        "' exists. Importing information"
      )
    )
    
    variables_user$LUT$session <<-
      read_csv(variables_environment$files$lut$lut_sessions)
    print("This is your session input: ")
    print.data.frame(variables_user$LUT$session)
    
    cat("\n\n")
    check_session_plausibility(variables_user$LUT$session$session_id_BIDS)
    cat("\n\n")
    
    print("Comparing for new sessions")
    unique_variables <- unique_variables %>%
      filter(!(session_id %in% variables_user$LUT$session$session_id))
    if(nrow(unique_variables) == 0) {print("No new session-id found.")}
    else {
      print("New session-id identified. Appended to lut-session.csv")
      print.data.frame(unique_variables)
      write_csv(unique_variables,
                variables_environment$files$lut$lut_sessions,
                append = TRUE)
      stop("Script aborts - New session-id added. Please edit the lut_session.csv file. Then start script again.")
    }
  }
  # Subject ID cleaning
  clean_foldernames <- function(df, 
                                lut_session = variables_user$LUT$session,
                                subject_regex = variables_user$LUT$study_info$subject_id_regex,
                                group_regex = variables_user$LUT$study_info$group_id_regex,
                                pattern_remove = variables_user$LUT$study_info$remove_pattern_regex,
                                output = variables_environment$directories$needed$nii) {
    df <- df %>%
      mutate(
        subjects_BIDS = your_subject_id %>%
          str_remove_all(regex("plus", ignore_case = TRUE)) %>%
          str_remove_all(regex(pattern_remove, ignore_case = TRUE)) %>%
          str_remove("10738BiDirecteigentlich"),# for BiDirect!
        group_BIDS = str_extract(subjects_BIDS, regex(group_regex)),
        session_BIDS = stri_replace_all_regex(
          your_session_id,
          lut_session$session_id,
          lut_session$session_id_BIDS,
          vectorize_all = FALSE
        ),
        nii_temp = paste0(
          output,
          "/ses-",
          session_BIDS,
          "/sub-",
          subjects_BIDS
        )
      )
    # 
    # df %>% select(subjects_BIDS) %>%
    #   mutate(subjects = str_replace(subjects_BIDS, subject_regex, "")) %>%
    #   filter(!is.na(subjects)) %>% print()
    # 
    return(df)
  }
  # print(dicoms_mapping)
  cat("\n\n")
  
  print("Subject-id detection, cleaning and plausibility check")
  Sys.sleep(2)
  diagnostics <<-
    list(dcm2nii_paths = clean_foldernames(df = dicoms_mapping))
    # Checking for implausible subject names
    check_subject_nomenclature <-
    function(subjects_BIDS, subject_regex) {
      if (any(str_detect(subjects_BIDS, subject_regex, negate = TRUE))) {
        diagnostics$dcm2nii_paths %>%
          filter(
            str_detect(
              subjects_BIDS,
              variables_user$LUT$study_info$subject_id_regex
            ) == 0
          ) %>%
          print.data.frame()
        write_csv(
          diagnostics$dcm2nii_paths,
          variables_environment$files$diagnostic$dcm2niix_paths
        )
        print(
          paste(
            "Implausible subjects_BIDS found - look into file: ",
            variables_environment$files$diagnostic$dcm2niix_paths
          )
        )
        stop(
          "Code breaks here: Implausible subjects_BIDS id found - please edit lut_study_info to edit your regex and the patterns to remove. Then start again."
        )
      } else {
        print(
          paste(
            "Filename cleaning done, subjects_BIDS pattern recognized. Diagnostic output: ",
            variables_environment$files$diagnostic$dcm2niix_paths
          ))
          print.data.frame(diagnostics$dcm2nii_paths)
          dir.create(variables_environment$directories$needed$user_diagnostics, 
                     showWarnings = FALSE, 
                     recursive = TRUE)
          write_csv(
            diagnostics$dcm2nii_paths,
            "user/diagnostics/step1_dcm2nii_paths_csv.csv"
          )

          Sys.sleep(2)
      }
    }
  
  check_subject_nomenclature(
    subjects_BIDS = diagnostics$dcm2nii_paths$subjects_BIDS,
    subject_regex = variables_user$LUT$study_info$subject_id_regex
  )
print("=============================================================")
print("Congratulations: The dcm2bids-preparation was successfull!")
}



# dcm2niix conversion functions -------------------------------------------

dcm2nii_wrapper <-
  function(input,
           output,
           scanner_type,
           dcm2niix_path = variables_environment$directories$setup$dcm2niix_path) {
    if (scanner_type == "Philips") {
      commands <- tibble(
        nii = paste0(dcm2niix_path,
                     " -o ",
                     output,
                     " -ba y -f %d -z y ",
                     input),
        json = paste0(
          dcm2niix_path,
          " -o ",
          str_replace(
            output,
            variables_environment$directories$needed$nii,
            variables_environment$directories$needed$json_sensitive
          ),
          " -b o -ba n -f %d -t y -z y ",
          input
        )
      )
    } else if (scanner_type == "Siemens") {
      stop("Not supported")
    } else if (scanner_type == "GE") {
      stop("Not supported")
    } else {
      stop(
        "Wrong scanner type: choose between 'Philips', 'Siemens', 'GE' (only tested on Philips)!"
      )
    }
    return(commands)
  }


## dicom converter

dcm2nii_converter <- function(list, output_folder){
  start_timer <- start_time()
  for (i in seq_along(list)) {
    done_file <- paste0(output_folder[i], "/done.txt")
    if (file.exists(done_file) == 0) {
    list_items(i, list, string = "dcm2niix conversion: output nii.gz + json.header (removing sensitive information like birthdate, gender, weight, id")
    dir.create(output_folder[i],
               recursive = TRUE,
               showWarnings = FALSE)
    measure_time(i, list, start_timer)

      system(list[i], )
      write_file("done", done_file)
    } else if (file.exists(done_file) == 1) {
      print("Skipped: Subject already processed - folder contains done.txt")
    }
  }
  measure_time(i, list, start_timer)
  print("===================================")
  print("Congratulation - the conversion was successful.")
  Sys.sleep(3)
}



# json extraction mapping -------------------------------------------------------
index_jsons <- function(path) {
  print("Indexing JSON files")
  start <- start_time()
  json <- list.files(
    path = paste0(path),
    pattern = ".json",
    full.names = FALSE,
    recursive = TRUE,
    include.dirs = TRUE
  ) 
  measure_time(1, 1, start)
  return(json)
}

get_json_headers <- function(json, working_dir) {
  setwd(working_dir)
  start <- start_time()
  
  mri_properties <- vector()
  str(mri_properties)
  for (i in 1:length(json)) {
    list_items(i, json, "Extraction of Headers - appending to one structure")
    measure_time(i, json, start)
    # Reading json headers
    mri_properties_new <- names(rjson::fromJSON(file = json[i]))
    mri_properties <- union(mri_properties, mri_properties_new)
  }
  # Building df
  names = mri_properties %>% sort()
  empty_df <- data.frame()
  for (k in names)
    empty_df[[k]] <- as.character()
  print("Success!")
  return(empty_df)
}

read_json_headers <- function(json, empty_df) {
  #setwd(working_dir)
  if (file.exists("../json_files.tsv") == 1) {
    file.remove("../json_files.tsv")
    print("../json_files.csv removed!")
  }
  
  start <- start_time()
  for (i in 1:length(json)) {
    list_items(i, json, "Reading metadata into structure")
    measure_time(i, json, start)
    result_new <- rjson::fromJSON(file = json[i], simplify = TRUE) %>% 
      lapply(paste, collapse = ", ") %>% 
      bind_rows() %>%
      mutate(Path = json[i])
    result_new <- merge(empty_df, result_new, all = TRUE, sort = F)
    result_new <- result_new[sort(names(result_new))]
    
    # result_new_1 <-
    #   result_new[, order(colnames(empty_df), decreasing = TRUE)]
    
    if (file.exists("../json_files.tsv") == 0) {
      write.table(
        result_new,
        "../json_files.tsv",
        sep = "\t",
        dec = ".",
        qmethod = "double",
        row.names = FALSE
      )
    } else {
      # Here data gets only appended to csv
      write.table(
        result_new,
        "../json_files.tsv",
        sep = "\t",
        dec = ".",
        qmethod = "double",
        row.names = FALSE,
        append = TRUE,
        col.names = FALSE
      )
    }
  }
  print("Done!")
}

extract_metadata <- function(df, number) {
  df %>% filter(level == number) %>% select_if(~!all(is.na(.)))
}

extract_json_metadata <- function(json_dir) {
  setwd(variables_environment$directories$setup$working_dir)
  json_files <- tibble(files = index_jsons(json_dir)) 
  metadata_empty_df <- get_json_headers(json_files$files, json_dir)
  metadata_df <- read_json_headers(json_files$files, metadata_empty_df)
  
}

read_metadata <- function() {
  metadata_df <- readr::read_tsv("../json_files.tsv") %>% 
    mutate(level = str_count(Path, "/"),
           input_json = paste0(variables_environment$directories$needed$nii, "/", Path)) %>% 
    separate(Path, into = c("session", "subject", "filename"), sep = "/") %>%
    mutate(sequence = str_remove_all(filename, ".json")) 
  return(metadata_df)
}


# sequence extraction and comparison --------------------------------------

extract_sequences <- function(df){
  sequences <- df %>%
    select(sequence, ProtocolName, SeriesDescription) %>% unique() 
  return(sequences)
}

mutate_sequence <- function(df){
  df <- df %>%
    mutate(BIDS_sequence_ID = "bids_sequence",
           type = "anat/dwi/func",
           relevant = "0/1")
  return(df)
}

check_sequence_plausibility <- function(df){
  if(any(is.na(df$BIDS_sequence_ID)) | any(str_detect(df$BIDS_sequence_ID, "bids_sequence"))) {
    stop("Planned error: empty or unedited 'BIDS_sequence_ID' column. Please edit 'BIDS_sequence_ID' in lut_sequences.csv")
  } else if (any(is.na(df$type)) | any(str_detect(df$type, "anat/dwi/func"))) {
    stop("Error: empty or unedited 'type' column. Please edit 'type' in lut_sequences.csv")
  } else if (any(is.na(df$relevant)) | any(str_detect(df$type, "0/1"))){
    stop("Error: empty or unedited 'relevant' column. Please edit 'relevant' in lut_sequences.csv")
  } else {
    print("Plausibility check passed.")
  }
}

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
  } else {
    print("File exists - update possible")
    sequences_old <<- read_csv(filename) %>% select(sequence, ProtocolName, SeriesDescription)
    sequences_df <- anti_join(sequences, sequences_old) 
    # print(sequences)
    print("Already edited sequences: ")
    cat("\n\n")
    print(sequences_old)
    cat("\n\n")
    if(nrow(sequences_df) > 0){
      cat("\n\n")
      print("New sequences: ")
      cat("\n\n")
      print.data.frame(sequences_df)
      cat("\n\n")
      #variables_user$LUT$sequences
      sequences_df <- sequences_df %>% mutate_sequence()
      write_csv(sequences_df,
                filename,
                append = TRUE)
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

apply_lut_sequence <- function(df){
  print.data.frame(variables_user$LUT$sequences)
  df <- df %>% 
    left_join(variables_user$LUT$sequences) %>% 
    mutate(
    group_BIDS = str_extract(subject, regex(variables_user$LUT$study_info$group_id_regex)),
    sequence_BIDS = stri_replace_all_regex(
      sequence,
      paste0("^",variables_user$LUT$sequences$sequence, "$"),
      variables_user$LUT$sequences$BIDS_sequence_ID,
      vectorize_all = FALSE
    ),
    BIDS_json = paste0(
      variables_environment$directories$needed$bids,
      "/", subject,
      "/", session,
      "/", type,
      "/", subject,
      "_", session,
      "_", sequence_BIDS, ".json"
  )) 
  df_diagnostic_sequence_mapping <- df %>% select(subject, session, sequence, type, input_json, BIDS_json, relevant) 
  print.data.frame(df_diagnostic_sequence_mapping, right = FALSE)
  write_csv(df_diagnostic_sequence_mapping, variables_environment$files$diagnostic$nii2BIDS_paths)
  # Output of sensitive informaion df
  df_sensitive_info <- df %>% select(subject, session, group_BIDS, PatientID, PatientName, AcquisitionDateTime, PatientBirthDate, PatientSex, PatientWeight) %>%
    mutate(AcquisitionDateTime = as.Date(AcquisitionDateTime),
           Age = time_length(difftime(AcquisitionDateTime, PatientBirthDate), "years") %>% round(digits = 2)) %>%
    unique()
  print.data.frame(df_sensitive_info)
  write_csv(df_sensitive_info, "user/diagnostics/sensitive_subject_information.csv")
  print("Sequence mapping was successful. Saved output to 'user/diagnostic/step2_nii_2_BIDS_paths.csv'. Please look for implausible sequences")
  return(df)
}




# copy2BIDS ---------------------------------------------------------------

copy2BIDS <- function(csv_file){
  csv_file <- read_csv(variables_environment$files$diagnostic$nii2BIDS_paths)
  csv_file_relevant <- csv_file %>% filter(relevant == 1) %>%
    mutate(input_nii = str_replace(input_json, ".json", ".nii.gz"),
           BIDS_nii = str_replace(BIDS_json, ".json", ".nii.gz"))
  csv_file_redundant <- csv_file %>% filter(relevant == 0)
  cat("\n\n")
  print("Relevant sequences files (copied2BIDS)")
  cat("\n\n")
  csv_file_relevant %>% select(sequence, relevant) %>% count(sequence) %>% print.data.frame()
  cat("\n\n")
  cat("\n\n")
  print("Irrelevant sequences files (skipped)")
  cat("\n\n")
  csv_file_redundant  %>% select(sequence, relevant) %>% count(sequence) %>% print.data.frame()
  cat("\n\n")
  cat("\n\n")
  
  csv_file_relevant_non_dwi <- csv_file_relevant %>% filter(type != "dwi") 
  csv_file_relevant_dwi <- csv_file_relevant %>% filter(type == "dwi") %>%
    mutate(input_bval = str_replace(input_json, ".json", ".bval"),
           input_bvec = str_replace(input_json, ".json", ".bvec"),
           BIDS_bval = str_replace(BIDS_json, ".json", ".bval"),
           BIDS_bvec = str_replace(BIDS_json, ".json", ".bvec")
  )
  path_to_folder(csv_file_relevant$BIDS_json)
  # non dwi
  file.copy(from = csv_file_relevant_non_dwi$input_json, to = csv_file_relevant_non_dwi$BIDS_json)
  file.copy(from = csv_file_relevant_non_dwi$input_nii, to = csv_file_relevant_non_dwi$BIDS_nii)
  # dwi
  file.copy(from = csv_file_relevant_dwi$input_json, to = csv_file_relevant_dwi$BIDS_json)
  file.copy(from = csv_file_relevant_dwi$input_nii, to = csv_file_relevant_dwi$BIDS_nii)
  file.copy(from = csv_file_relevant_dwi$input_bval, to = csv_file_relevant_dwi$BIDS_bval)
  file.copy(from = csv_file_relevant_dwi$input_bvec, to = csv_file_relevant_dwi$BIDS_bvec)
}




