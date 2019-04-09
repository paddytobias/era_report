suppressPackageStartupMessages(library(googlesheets))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(googledrive))
suppressPackageStartupMessages(library(reticulate))

# specifying which Python version to use. 
use_python("/Library/Frameworks/Python.framework/Versions/2.7/lib/site-python")

# authentication
gs_auth(token = "tokens/gs_token.rds") # authenticate for Google Sheets


report_log_id = "14dxjfgqXMQtCx8wi3CHnm4Pd1K0urHK786-uVwnWSh4"
research_support_id = "1BSzngasM_AYe54xZv6aqBu08_wE_Y_Jmnn9yGaYRL4o"
university = "Deakin"

## filtering log file for univesity-specific reports
deakin_log = suppressMessages(gs_key(as_id(report_log_id)) %>% 
  gs_read(ws = "log", verbose = F) %>% 
  filter(grepl(university, member)))

report_conn = gs_key(as_id(research_support_id))
deakin_research_support_report = suppressMessages(report_conn %>% 
  gs_read(ws = "research_support", verbose = F))

lastrow = nrow(deakin_research_support_report)

global = paste(deakin_research_support_report$year, deakin_research_support_report$month, deakin_research_support_report$campus, sep = "-")
for (i in 1:nrow(deakin_log)){
  condition = paste(deakin_log$year[i], deakin_log$month[i], gsub("(.*- )(.*)", "\\2", deakin_log$member[i]), sep = "-")
  
  if (!(condition %in% global)){
    ## globals
    month.reporting = deakin_log$month[i]
    year.reporting = deakin_log$year[i]
    campus = gsub("(.* - )(.*)", "\\2",deakin_log$member[i])
    
    message("\n\nCollecting Reseach Support entries for ", condition)
    
    ## get month report via id
    url_split = str_split(deakin_log$link[i], "/")[[1]]
    len = length(url_split)
    report_id = url_split[len-1]
    report_res_support = suppressMessages(gs_key(as_id(report_id)) %>% 
      gs_read(ws = "All month events", range = "A3:F1000", verbose = F) %>% 
      filter(Activity == "Research Support"))
    
    ## preparing to overwrite any entries for this month. Updating with latest data
    filter = data.frame(year = as.character(year.reporting), month = as.character(month.reporting))
    res_support_entry = deakin_research_support_report %>% 
      inner_join(filter)
    
    for (j in 1:nrow(report_res_support)){
      new_entry = data.frame("year" = as.character(year.reporting), 
                             "month" = as.character(month.reporting), 
                             "current state" = NA,
                             "researcher" = as.character(report_res_support$Contact[j]), 
                             "email" = NA,
                             "duties" = as.character(report_res_support$Task[j]),
                             "institute" = NA,
                             "campus" = as.character(campus), 
                             "faculty" = NA,
                             "school/area" = NA, 
                             "supervisor" = NA, 
                             "hours" = as.character(report_res_support$Hours[j]),
                             "acknowledgement" = NA, 
                             "co-authorship" = NA, 
                             "journal"= NA, 
                             "manuscript.title" = NA, 
                             "manuscript.status" = NA,
                             stringsAsFactors = F)
      
      res_support_entry = rbind(res_support_entry, new_entry)
    }
    
    res_support_entry  = res_support_entry %>% 
      select(year, month, current.state, researcher, email, duties,
             institute, campus, faculty, school.area, supervisor, 
             hours)
    
    ##---- ldap lookup - only for DEAKIN USE
    if (university=="Deakin" & file.exists("scripts/ldap_lookup.py")) {
      message("\n\nWorking on Deakin. Doing LDAP lookup on researchers.")
      suppressWarnings(dir.create("data"))
      write_csv(res_support_entry, path = "data/res_support_data.csv")
      
      
      py_run_file("scripts/ldap_lookup.py")
      
      ldap = suppressMessages(read_csv("data/ldap_lookup.csv") %>% 
        select(2:ncol(.)) %>% 
        distinct())
      
      res_support_entry = res_support_entry %>% 
        left_join(ldap, by = c("researcher" = "name")) %>% 
        select(year, month, current.state,
               researcher, email.y, duties, institute.y,
               campus, faculty.y, deakinArea, supervisor, 
               hours) %>% 
        rename("email" = "email.y", 
               "faculty" = "faculty.y", 
               "institute" = "institute.y")
      
      ###----
    }
    message("\n\nAdding latest Reseach Support entries")
    suppressWarnings(suppressMessages(report_conn %>% 
      gs_edit_cells(ws = "research_support", anchor = paste0("A", lastrow+2), 
                    input = res_support_entry, byrow = T,col_names = F)))
    lastrow = lastrow + nrow(res_support_entry)
    
    ## clean up
    unlink("data/", recursive = T)
  }
}

message("\n\nLatest Reseach Support entries added")


             