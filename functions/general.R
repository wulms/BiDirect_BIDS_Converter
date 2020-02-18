# general functions - these are used at different points of the script

options(readr.num_columns = 0)
options(width = 320)

#' Create folders from (list of) filenames
#'
#' @param list_of_files filename, list of filenames containing path
#'
#' @return Nothing - creates folders for these files on the system
#' @examples
#' path_to_folder("folder/subfolder/file.txt")
path_to_folder <- function(list_of_files) {
  paths_folder <- sub("[/][^/]+$", "", list_of_files)
  paths_folder <- unique(paths_folder)
  # print(head(paths_folder))
  lapply(paths_folder,
         dir.create,
         recursive = TRUE,
         showWarnings = FALSE)
}


#' Renders Asci Art from txt files.
#'
#' @param asci_file txt file containing the asci code
#'
#' @return Prints asci to console
#'
#' @examples render_asci_art("asci_file.txt")
render_asci_art <- function(asci_file){
  asci <- readLines(paste0(variables_environment$directories$setup$repo_dir, "/", asci_file), warn=FALSE)
  # asci <- dput(asci)
  cat(asci, sep = "\n")
}

#' Prints progress of files in list of files
#'
#' @param item item in for loop
#' @param list_of_files list, where the item comes from
#' @param start Sys.time() of start, used to calculate the time difference
#' @param string String, to describe the function of the loop

print_passed_time <- function(item, list_of_files, start, string) {
  if(item %% 10 == 0){
    if(os == "Windows"){
      #system("cls")
      cat("\014")
    } else {
      #system("clear")
      cat("\014")
    }
  }
  end <- Sys.time()
  time_difference <- difftime(end, start, unit = "mins") %>% round(2)
  time_info <- paste("Time since start: ", time_difference %>% round(0), " min.  ETA: ",  (difftime(end, start, unit = "mins")/item*length(list_of_files) - time_difference) %>% round(0), " min. remaining.")
  file_info <- paste(" ", item, " / ", length(list_of_files), " total. (", round(item / length(list_of_files) * 100, 0), "%) - list item:", list_of_files[item])
  print(paste(string, time_info, file_info))
}




















