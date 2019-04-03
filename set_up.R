mirror = "https://mirror.aarnet.edu.au/pub/CRAN/"
# dependencies:
install.packages("httpuv", repos=mirror)
install.packages("devtools", repos = mirror)
devtools::install_github("paddytobias/googlecalendar")
install.packages("dplyr", repos = mirror)
install.packages("googlesheets", repos = mirror)
install.packages("chron", repos = mirror)
install.packages("lubridate", repos = mirror)
install.packages("googledrive", repos = mirror)
devtools::install_github("paddytobias/gmailr")
install.packages("jsonlite", repos = mirror)
