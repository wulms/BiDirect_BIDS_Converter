
packages <- c("dplyr", "tidyr", "stringr", "stringi", "readr", 
              "lubridate", "rjson", 
              "flexdashboard", "knitr", 
              "DT", "plotly", "cowplot", "ggplot2", 
              "lavaan", "smooth", "Hmisc")

if (!require("pacman")) install.packages("pacman", repos = "https://cran.us.r-project.org")
pacman::p_load(packages, character.only = TRUE)


# # libraries
# library(readr)
# library(dplyr)
# library(tidyr)
# library(stringr)
# library(stringi)
# library(forcats)
# library(lubridate)
# 
# library(rjson)

