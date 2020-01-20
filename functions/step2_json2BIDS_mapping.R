index_jsons <- function(path) {
  
  tic()
  json <- list.files(path = paste0(path),
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



