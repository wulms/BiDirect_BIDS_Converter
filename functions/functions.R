list_dicom_folders <- function(input_folder) {
  dir(input_folder, full.names = TRUE) %>% 
    lapply(FUN = dir, recursive = FALSE, full.names = TRUE) %>% 
    unlist() %>% 
    data.frame(dicoms = ., stringsAsFactors = FALSE)
}

clean_foldernames <- function(pattern_remove) {
  dicoms_mapping %>%
    mutate(subjects_old = str_split(dicoms, "/", simplify = TRUE)[,3],
           survey = str_split(dicoms, "/", simplify = TRUE)[,2],
           subjects_new = subjects_old %>% str_remove_all("[:punct:]{1}|[:blank:]{1}") %>%
             str_remove_all(regex("plus", ignore_case = TRUE)) %>%
             str_remove_all(regex(pattern_remove, ignore_case = TRUE)) %>%
             str_remove("10738BiDirecteigentlich"),
           nii_temp = paste0(temp_folder, survey, "/", subjects_new))
}

diag_mapping <- function(df) {
  df %>%
    select(subjects_old, subjects_new) %>%
    mutate(subjects_old = str_remove(subjects_old, patterns$subjects),
           subjects_new = str_remove(subjects_new, patterns$subjects)) %>%
    group_by_all() %>%
    count()
}

diag_implausible_names <- function(df) {
  df %>%
    select(nii_temp) %>%
    filter(str_detect(nii_temp,pattern = paste0("/", patterns$subjects, "$"), negate = TRUE) == 1)
}


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
    system(system_string)
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
        "/home/niklas/Downloads/dcm2niix_lnx/dcm2niix ",
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
        # "-f %d ",
        input[i]
      )
    print(system_string)
    system(system_string)
  }
}


index_jsons <- function(path) {
  
  tic()
  json <- list.files(path = paste0(working_dir, path),
                     pattern = ".json",
                     full.names = TRUE,
                     recursive=TRUE,
                     include.dirs = TRUE) %>%
    str_replace(working_dir, "")
  toc()
  return(json)
}

difference_check_jsons <- function(json, json_csv) {
  if (file.exists(json_csv) == 1) {
    json_proc <- read.table(json_csv,
                            header = TRUE,
                            sep = ",",
                            dec = ".",
                            stringsAsFactors = FALSE
                            #row.names = 0
    )$Path
    
    print(head(json_proc))
    #json_processed <- json_proc$Path
    
    # checks for already processed jsons
    json_diff <- setdiff(json, json_proc)
    print(head(json_diff))
    return(json_diff)
  } else {
    print("No json_files.csv exists - will be created in the next steps")
    return(json)
  }
}


get_json_headers <- function(json) {
  tic()
  for (i in 1:length(json)) {
    cat("\014")
    print(paste(i, "of length", length(json), round(i/length(json)*100, 1), "%", "json:", json[i]))
    
    if (i == 1) {
      mri_properties_new <- names(fromJSON(file = json[i]))
      mri_properties <- mri_properties_new
    }  
    
    if (i > 1) {
      mri_properties_new <- names(fromJSON(file = json[i]))
      mri_properties <- union(mri_properties, mri_properties_new)
      # print(setdiff(mri_properties, mri_properties_new))
    }
  }
  
  names = mri_properties %>% sort()
  empty_df <- data.frame()
  for (k in names) empty_df[[k]] <- as.character()
  toc()
  return(empty_df)
}

read_json_headers <- function(json, empty_df) {
  setwd(working_dir)
  for (i in 1:length(json)) {
    tic()
    print(cat("\014"))
    print(paste(i, "of length", length(json), round(i/length(json)*100, 1), "%", "json:", json[i]))
    
    result_new <- fromJSON(file = json[i]) 
    
    result_new$ImageType <- paste(result_new$ImageType, collapse = ", ")
    result_new$ImageOrientationPatientDICOM <- paste(result_new$ImageOrientationPatientDICOM, collapse = ", ") 
    
    result_new <- result_new %>%
      as.data.frame(stringsAsFactors = FALSE) %>%
      mutate(Path = json[i]) %>%
      unique()
    
    result_new <-merge(empty_df, result_new, all = TRUE, sort = F) 
    result_new <- result_new[sort(names(result_new))]
    
    result_new_1 <- result_new[, order(colnames(empty_df),decreasing=TRUE)]
    
    if (file.exists("json_files.csv") == 0) {
      write.table(result_new,
                  "json_files.csv",
                  sep = ",",
                  dec = ".",
                  qmethod = "double",
                  row.names = FALSE)
    } else {
      # Here data gets only appended to csv
      write.table(result_new,
                  "json_files.csv",
                  sep = ",",
                  dec = ".",
                  qmethod = "double",
                  row.names = FALSE,
                  append = TRUE,
                  col.names = FALSE)
    }
  }
  
  toc()
}

