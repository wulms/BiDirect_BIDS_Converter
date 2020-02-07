# Preparation functions ---------------------------------------------------

#' Creates file templates, for the user to edit
#'
#' @return Creates .csv files on the filesystem
create_templates <- function () {
  setwd(variables_environment$directories$setup$working_dir)
  if (file.exists(variables_environment$files$lut$lut_study_info) == 0) {
    print("Creating user folder")
    dir.create(variables_environment$directories$needed$user_settings, showWarnings = FALSE, recursive = TRUE)
    print("Creating template files --------")
    # Study info file <- user edit
    write_csv(variables_environment$templates$variables, variables_environment$files$lut$lut_study_info)
    # Template file
    write_csv(variables_environment$templates$variables, variables_environment$files$lut$example_lut_study_info)
    print(paste("Please edit '", variables_environment$files$lut$lut_study_info,"' - the '", variables_environment$files$lut$example_lut_study_info, "' is a template for editing."))
    render_asci_art("asci/error_study_info.txt")
    stop("Script aborts: Please edit the file and restart the code.")
  } else {
    print(paste("The template file:'",  variables_environment$files$lut$lut_study_info, "' was found."))
    # Global variable assignment here!
    variables_user <<- list(LUT = list(study_info = read_csv(variables_environment$files$lut$lut_study_info) 
                                      #  %>% mutate(subject_id_regex = paste0("^", subject_id_regex, "$"))
                                       ))
    print(variables_user$LUT$study_info)
    print("Next step: list dicom folders, and extract session information")
    # return(variables_user)
  }
}