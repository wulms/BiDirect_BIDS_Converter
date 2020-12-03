
packages <- c("tidyverse", "stringi", "lubridate", "rjson", "flexdashboard", "knitr", "DT", "lattice", "plotly",
              "devtools")

if (!require("pacman")) install.packages("pacman", repos = "https://cran.us.r-project.org")
pacman::p_load(packages, character.only = TRUE)

devtools::install_github("muschellij2/papayaWidget")

library("papayaWidget")
