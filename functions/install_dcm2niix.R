# install dcm2niix 

#' installs dcm2niix from Chris Rordens Github Repository, also depending on OS
#'
#' @examples install_dcm2niix()
install_dcm2niix <- function() {
  if (length(list.files(pattern = "dcm2niix")) == 0) {
    os <- Sys.info()["sysname"]
    if (os == "Darwin") {
      message("Identified MacOs. Not officially supported!")
      dcm2niix <-
        "https://github.com/rordenlab/dcm2niix/releases/download/v1.0.20190902/dcm2niix_mac.zip"
    }
    else if (os == "Linux") {
      message("Identified Linux.")
      dcm2niix <-
        "https://github.com/rordenlab/dcm2niix/releases/download/v1.0.20190902/dcm2niix_lnx.zip"
    }
    else if (os == "Windows") {
      message("Identified windows.")
      dcm2niix <-
        "https://github.com/rordenlab/dcm2niix/releases/download/v1.0.20190902/dcm2niix_win.zip"
    } else {
      print(Sys.info()["sysname"])
      stop("OS not identified. Please issue the sysname on Github.")
    }
    download.file(dcm2niix, "dcm2niix.zip")
    unzip("dcm2niix.zip")
    file.remove("dcm2niix.zip")
    if (os == "Linux") {
      Sys.chmod("dcm2niix", mode = "0777")
    }
  }
}

