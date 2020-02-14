# copy2BIDS ---------------------------------------------------------------


#' Copies files, if they don't exist in target
#'
#' @param from list: File source
#' @param to list: File destination
#' @param string Which step?
#'
#' @examples copy_files(path_input, path_output, "Copy files to output.")
copy_files <- function(from, to, string){
  df <- tibble(from = from,
               to = to) %>%
    filter(file.exists(to) == 0)
  if(nrow(df) > 0) {
    start_timer <- Sys.time()
    for (i in seq(df$from)) {
      # print(paste("Copied file ", i, " of ", length(from),  " to: ", to[i]))
      # if(file.exists(to[i]) == 0) {
      print_passed_time(i, df$to, start_timer, "Copying2BIDS: ")
      file.copy(df$from[i], df$to[i], overwrite = FALSE)
    }
    print(string)
    cat("\n\n")
  } else {print(paste0(string, " already existing - skipped"))}  
}

#' Prepares and copies files to BIDS
#'
#' @param csv_file 
#'
#' @return
#' @export
#'
#' @examples
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
  copy_files(from = csv_file_relevant_non_dwi$input_json, to = csv_file_relevant_non_dwi$BIDS_json, "Copy2BIDS: non-dwi jsons")
  copy_files(from = csv_file_relevant_non_dwi$input_nii, to = csv_file_relevant_non_dwi$BIDS_nii, "Copy2BIDS: non-dwi nii")
  # dwi
  copy_files(from = csv_file_relevant_dwi$input_json, to = csv_file_relevant_dwi$BIDS_json, "Copy2BIDS: dwi json")
  copy_files(from = csv_file_relevant_dwi$input_nii, to = csv_file_relevant_dwi$BIDS_nii, "Copy2BIDS: dwi nii")
  copy_files(from = csv_file_relevant_dwi$input_bval, to = csv_file_relevant_dwi$BIDS_bval, "Copy2BIDS: dwi bval")
  copy_files(from = csv_file_relevant_dwi$input_bvec, to = csv_file_relevant_dwi$BIDS_bvec, "Copy2BIDS: dwi bvec")
}