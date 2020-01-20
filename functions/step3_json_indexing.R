  get_json_headers <- function(json) {
  # The function reads the variable names from each header (without extracting the actual attributes) - This is a crucial step before applying read_json_headers.
  # Output is an empty dataframe containing the headers, where in the next step the information is added to.
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
  json_header_df <- data.frame()
  for (k in names) json_header_df[[k]] <- as.character()
  toc()
  return(json_header_df)
}

read_json_headers <- function(json, json_header_df) {
  # The function
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
    
    result_new <-merge(json_header_df, result_new, all = TRUE, sort = F) 
    result_new <- result_new[sort(names(result_new))]
    
    result_new_1 <- result_new[, order(colnames(json_header_df),decreasing=TRUE)]
    
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
