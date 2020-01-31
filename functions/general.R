# general functions - these are used at different points of the script

path_to_folder <- function(list_of_files){
  
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
    print("Please wait 10 seconds and take care, that these options are right")
    Sys.sleep(10)
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
  print("These files were found (max. 25 shown).")
  print.data.frame(dicoms_mapping, max = 25)
  Sys.sleep(2)
  # Session ID unique readout
  unique_variables <-
    tibble(
      session_id = unique(dicoms_mapping$your_session_id),
      session_id_BIDS = "1/2/.../4 or more?"
    )
  print("Unique sessions identified:")
  print(unique_variables)
  Sys.sleep(2)
  
  # Session ID update, plausibility check and readout
  check_session_plausibility <- function(input) {
    if (any(str_detect(input, "more"),na.rm = TRUE)) {stop("Found a row, that was not edited (still contains 'more') in the lut_sessions.csv. Please edit the file again.")}
    else if (any(is.na(input))) {stop("Found a row, that is empty in the lut_sessions.csv. Please edit the file again.") }
    else if (any(str_detect(input, "[:punct:]"))) {stop("Found a row, that contains punctuation. Please use only alphanumeric signs.")}
    else if (any(str_detect(input, "[:blank:]"))) {stop("Found a row, that contains a blank. Please use only alphanumeric signs.")}
    else {print("Your lut_sessions.csv looks fine.")}
  }
  
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
    
    check_session_plausibility(variables_user$LUT$session$session_id_BIDS)
    
    print("Comparing for new sessions")
    unique_variables <- unique_variables %>%
      filter(!(session_id %in% variables_user$LUT$session$session_id))
    if(nrow(unique_variables) == 0) {print("No new session-id found.")}
    else {
      print("New session-id identified. Apoended to lut-session.csv")
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
          str_remove_all("[:punct:]{1}|[:blank:]{1}") %>%
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
  print(dicoms_mapping)
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
          write_csv(
            diagnostics$dcm2nii_paths,
            variables_environment$files$diagnostic$dcm2niix_paths
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
    list_items(i, list, string = "dcm2niix conversion: output nii.gz + json.header (removing sensitive information like birthdate, gender, weight, id")
    done_file <- paste0(output_folder[i], "/done.txt")
    dir.create(output_folder[i],
               recursive = TRUE,
               showWarnings = FALSE)
    measure_time(i, list, start_timer)
    if (file.exists(done_file) == 0) {
      system(list[i])
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



# json2bids mapping -------------------------------------------------------


