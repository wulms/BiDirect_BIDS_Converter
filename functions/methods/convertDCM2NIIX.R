# dcm2niix conversion functions -------------------------------------------

#' Creates the dcm2niix system commands for the conversion
#'
#' @param input Folder path(s) containing dicoms 
#' @param output Folder path(s) where the nii images should be exported to
#' @param scanner_type MRI scanner vendor type
#' @param dcm2niix_path Path to dcm2niix tool on your system
#'
#' @return List of dcm2niix system commands
#'
#' @examples
#' dcm2nii_wrapper("root_folder/session_id/participant_id/", "nii/session-id/participant-id/")
dcm2nii_wrapper <-   function(input_folder, output_folder, scanner_type, dcm2niix_path = variables_environment$directories$setup$dcm2niix_path) {
    if (scanner_type == "Philips" | scanner_type == "Siemens") {
      commands <- tibble(
        nii = paste0(dcm2niix_path, " -o ", output_folder, 
                     " -ba y -f %d -z y ", input_folder),
        json = paste0(dcm2niix_path, " -o ", str_replace(output_folder, 
                                                         variables_environment$directories$needed$nii,
                                                         variables_environment$directories$needed$json_sensitive),
                      " -b o -ba n -f %d -t y -z y ", input_folder)
      )
    } else if (scanner_type == "GE") {stop("Not supported")
    } else {stop("Wrong scanner type: choose between 'Philips', 'Siemens', 'GE' (only tested on Philips|Siemens)!")
    }
    return(commands)
  }


## dicom converter

#' dcm2niix system calls using a list from dcm2nii_wrapper
#'
#' @param list from dcm2nii_wrapper 
#' @param output_folder list of output folders 
#'
#' @examples
#' dcm2nii_converter("dcm2niix -o nii/session-id/participant-id/ -ba y -f %d -z y root_folder/session_id/participant_id/")
dcm2nii_converter <- function(list, output_folder){
  start_timer <- start_time()
  for (i in seq_along(list)) {
    done_file <- paste0(output_folder[i], "/done.txt")
    if (file.exists(done_file) == 0) {
      cat("/n")
      dir.create(output_folder[i], recursive = TRUE, showWarnings = FALSE)
      measure_time(i, list, start_timer, "dcm2niix (by Chris Rorden) conversion: ")
      system(list[i])
      write_file("done", done_file)
    } else if (file.exists(done_file) == 1) {
      print("Skipped: Subject already processed - folder contains done.txt")
    }
  }
  measure_time(i, list, start_timer, "dcm2niix (by Chris Rorden) conversion: ")
  print("===================================")
  print("Congratulation - the conversion was successful.")
}
