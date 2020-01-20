# dcm2niix functions

## dicom converter
list_dicom_folders <- function(input_folder) {
  df <- dir(input_folder, full.names = TRUE) %>% 
    lapply(FUN = dir, recursive = FALSE, full.names = TRUE) %>% 
    unlist() %>% 
    data.frame(dicom_folder = ., stringsAsFactors = FALSE)  %>%
    mutate(your_session_id = str_split(dicom_folder, "/", simplify = TRUE)[,2],
           your_subject_id = str_split(dicom_folder, "/", simplify = TRUE)[,3])
  return(df)
  }

clean_foldernames <- function(pattern_remove) {
  
  dicoms_mapping %>%
    mutate(subjects_BIDS = your_subject_id %>% str_remove_all("[:punct:]{1}|[:blank:]{1}") %>%
             str_remove_all(regex("plus", ignore_case = TRUE)) %>%
             str_remove_all(regex(pattern_remove, ignore_case = TRUE)) %>%
             str_remove("10738BiDirecteigentlich"),
           group_BIDS = str_extract(subjects_BIDS, user_study_info$group_id_regex),
           session_BIDS = stri_replace_all_regex(your_session_id, user_session_info$your_session_id, user_session_info$session_BIDS, vectorize_all = FALSE),
           nii_temp = paste0(directories$NII_temp_dir, "/", session_BIDS, "/", subjects_BIDS))
}

# diag_mapping <- function(df) {
#   df %>%
#     select(subjects_old, subjects_new) %>%
#     mutate(subjects_old = str_remove(subjects_old, patterns$subjects),
#            subjects_new = str_remove(subjects_new, patterns$subjects)) %>%
#     group_by_all() %>%
#     count()
# }
# 
# diag_implausible_names <- function(df) {
#   df %>%
#     select(nii_temp) %>%
#     filter(str_detect(nii_temp,pattern = paste0("/", patterns$subjects, "$"), negate = TRUE) == 1)
# }


dcm2niix_anonymized <- function(input, output) {
  for (i in 1:length(input)) {
    #foreach (i = 1:length(dicoms_mapping$dicoms)) %dopar% {
    cat("\014")
    print(paste(i, "of length", length(input), round(i/length(input)*100, 1), "%", "json:", input[i]))
    
    # Creation of folders
    #  if (dir.exists(dicoms_mapping$nii_temp[i]) == 0) {
    dir.create(output[i],
               recursive = TRUE,
               showWarnings = FALSE)
    
    system_string <-
      paste0(
        dcm2niix_path, "dcm2niix ",
        " -ba y ",
        # BIDS sidecar and anonymization
        #   "-x n ", # crop 3d
        "-o ", output[i], " ",
        # output directory
        #   "-z y ",
        "-i y ",
        # ignore derived
        #    "-t y ", # private text informations
        #   "-v 0 ", # verbose turned off
        #   "-w 0 ", # skips overwriting when name is conflicting
        "-f %d -w 0 ",
        input[i]
      )
    print(system_string)
    if(file.exists(paste0(output[i], "/done.txt")) == 0){
      system(system_string)
      write_file("", paste0(output[i], "/done.txt"))
    } else {
      print(paste0("This folder was already processed: ", output[i], " ---- skipping to next participant."))
    }
    
  }
}


dcm2niix_header_extraction <- function(input, output) {
  
  # Conversion of Dicom 2 Nifti
  for (i in 1:length(input)) {
    cat("\014")
    print(paste(i, "of length", length(input), round(i/length(input)*100, 1), "%", "json:", input[i]))
    
    # Creation of folders
    #  if (dir.exists(dicoms_mapping$nii_temp[i]) == 0) {
    dir.create(output[i],
               recursive = TRUE,
               showWarnings = FALSE)
    
    system_string <-
      paste0(
        dcm2niix_path, "dcm2niix ",
        " -b o ",
        # BIDS sidecar and anonymization - o outputs only HEADER files!
        #   "-x n ", # crop 3d
        "-o ",
        output[i],
        " ",
        # output directory
        #   "-z y ",
        # ignore derived
        #    "-t y ", # private text informations
        #   "-v 0 ", # verbose turned off
        #   "-w 0 ", # skips overwriting when name is conflicting
        "-f %d -w 0 ",
        input[i]
      )
    print(system_string)
    if(file.exists(paste0(output[i], "/done.txt")) == 0){
      system(system_string)
      write_file("", paste0(output[i], "/done.txt"))
    } else {
      print(paste0("This folder was already processed: ", output[i], " ---- skipping to next participant."))
    }
  }
}