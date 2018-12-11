# look up report authority
source("libraries.R")
source("functions.R")


report_authority_id = "1G2YadcphdT1xkf6VJLiF-zvaLYd3a113avNJCMsB930"

config_data = report_gs(report_authority_id) %>% 
  gs_read(ws = "config")


