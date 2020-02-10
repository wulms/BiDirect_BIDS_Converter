# json extraction mapping -------------------------------------------------------

#' Finds json files in a directory
#'
#' @param path path, where you want to search for .json files
#'
#' @return a list of json files
#' @examples index_jsons("BIDS/sourcedata")
index_jsons <- function(path) {
  # print("Indexing JSON files")
  start_timer <- Sys.time()
  json <- list.files(path = paste0(path), pattern = ".json", full.names = FALSE, recursive = TRUE, include.dirs = TRUE  ) 
  print_passed_time(1, 1, start_timer, "Indexing")
  return(json)
}

#' Extracts json headers from multiple files with different headers
#'
#' @param json a list of json files
#' @param working_dir directory
#'
#' @return empty dataframe with each unique column found in one json file
#' 
#' @examples get_json_headers(list_of_jsons)
get_json_headers <- function(json, working_dir) {
  setwd(working_dir)
  start_timer <- Sys.time()
  mri_properties <- vector()
  str(mri_properties)
  for (i in 1:length(json)) {
    print_passed_time(i, json, start_timer, "Extraction of Headers: ")
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
  empty_df <- empty_df %>% mutate(Path = NULL)
  return(empty_df)
}

#' Extracts the information from each json and merges it to the dataframe.
#' Depends on existing columns! Identified by get_json_headers
#'
#' @param json list of json files
#' @param empty_df empty dataframe containing all unique headers, that exist in one of the json files
#'
#' @return writes a tsv containing all headers
#' @export
#'
#' @examples read_json_headers(json_list, empty_df_with_headers)
read_json_headers <- function(json, empty_df) {
  if (file.exists(variables_environment$files$diagnostic$metadata) == 1) {
    print("Delete file")
    file.remove(variables_environment$files$diagnostic$metadata)
  }
  start_timer <- Sys.time()
  for (i in 1:length(json)) {
    print_passed_time(i, json, start_timer, "Extracting metadata of Headers: ")
    result_new <- rjson::fromJSON(file = json[i], simplify = TRUE) %>% 
      lapply(paste, collapse = ", ") %>% 
      bind_rows() %>%
      mutate(Path = json[i])
    result_new <- merge(empty_df, result_new, all = TRUE, sort = F)
    result_new <- result_new[sort(names(result_new))]
    if (file.exists(variables_environment$files$diagnostic$metadata) == 1) {write.table(result_new, variables_environment$files$diagnostic$metadata,  append = TRUE,
                                                                                        sep = "\t", dec = ".", qmethod = "double", row.names = FALSE, col.names = FALSE)}
    if (file.exists(variables_environment$files$diagnostic$metadata) == 0) {write.table(result_new, variables_environment$files$diagnostic$metadata,
                                                                                        sep = "\t", dec = ".", qmethod = "double", row.names = FALSE)} 
  }
  print("Done!")
}


#' Wrapper function for indexing, unique header finding and metadata extraction from jsons.
#'
#' @param json_dir directory containing json files 
#'
#' @return writes a file containing all extracted information
extract_json_metadata <- function(json_dir) {
  setwd(variables_environment$directories$setup$working_dir)
  json_files <- tibble(files = index_jsons(json_dir))
  metadata_empty_df <- get_json_headers(json_files$files, json_dir)
  read_json_headers(json_files$files, metadata_empty_df)
}


#' Reads the local json metadata file into a dataframe
#'
#' @return a modified dataframe containing the json information
#' @examples read_metadata()
read_metadata <- function() {
  metadata_df <- readr::read_tsv(variables_environment$files$diagnostic$metadata) %>% 
    mutate(level = str_count(Path, "/"),
           input_json = paste0(variables_environment$directories$needed$nii, "/", Path)) %>% 
    separate(Path, into = c("session", "subject", "filename"), sep = "/") %>%
    mutate(sequence = str_remove_all(filename, ".json")) 
  return(metadata_df)
}

