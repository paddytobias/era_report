library(googlesheets)
library(stringr)
library(tidyverse)
library(googledrive)
library(reticulate)
use_python("/Library/Frameworks/Python.framework/Versions/2.7/lib/site-python")

setwd("~/Syncplicity Folders/RDS26026-Work/Deakin/res_support/")
source("scripts/config.r")



report_log_id = "14dxjfgqXMQtCx8wi3CHnm4Pd1K0urHK786-uVwnWSh4"
research_support_report_id = "1BSzngasM_AYe54xZv6aqBu08_wE_Y_Jmnn9yGaYRL4o"

## filtering Deakin reports
deakin_reports = gs_key(as_id(report_log_id)) %>% 
  gs_read(ws = "log") %>% 
  filter(grepl("Deakin", member))

deakin_research_support_report_conn = gs_key(as_id(research_support_report_id))
deakin_research_support_report = deakin_research_support_report_conn %>% 
  gs_read(ws = "research_support")
lastrow = nrow(deakin_research_support_report)

for (i in 1:nrow(deakin_reports)){
  condition = paste0(deakin_reports$year[i], deakin_reports$month[i], gsub("(.*- )(.*)", "\\2", deakin_reports$member[i]))
  global = paste0(deakin_research_support_report$year, deakin_research_support_report$month, deakin_research_support_report$campus)
  
  if (!(condition %in% global)){
    url_split = str_split(deakin_reports$link[i], "/")[[1]]
    len = length(url_split)
    report_id = url_split[len-1]

    report_res_support = gs_key(as_id(report_id)) %>% 
      gs_read(ws = "All month events", range = "A4:F200") %>% 
      filter(Activity == "Research Support")
    
    month.reporting = deakin_reports$month[i]
    year.reporting = deakin_reports$year[i]
      
    filter = data.frame(year = as.character(year.reporting), month = as.character(month.reporting))
    deakin_research_support_report_filtered = deakin_research_support_report %>% 
      inner_join(filter)
    
    campus = gsub("(.* - )(.*)", "\\2",deakin_reports$member[i])
    res_support_entry = data.frame("year" = as.character(), 
                                   "month" = as.character(), 
                                   "current state" = as.character(),
                                   "researcher" = as.character(), 
                                   "email" = as.character(),
                                   "duties" = as.character(),
                                   "institute" = as.character(),
                                   "campus" = as.character(), 
                                   "faculty" = as.character(),
                                   "school/area" = as.character(), 
                                   "supervisor" = as.character(), 
                                   "hours" = as.character(),
                                   "acknowledgement" = as.character(), 
                                   "co-authorship" = as.character(), 
                                   "journal"= as.character(), 
                                   "manuscript.title" = as.character(), 
                                   "manuscript.status" =as.character(),
                                   stringsAsFactors = F)
    
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
    
    deakin_research_support = rbind(deakin_research_support_report_filtered, res_support_entry, stringsAsFactors = F)
    suppressWarnings(dir.create("data"))
    write_csv(deakin_research_support, path = "data/res_support_data.csv")
    
    
    ##---- ldap lookup - only for DEAKIN USE
    py_run_file("scripts/ldap_lookup.py")
    
    ldap = read_csv("data/ldap_lookup.csv") %>% 
      select(2:ncol(.)) %>% 
      distinct()
    ###----
    
    res_support_join = deakin_research_support %>% 
      left_join(ldap, by = c("researcher" = "name")) %>% 
      select(year, month, current.state,
             researcher, email.y, duties, institute.y,
             campus, faculty.y, deakinArea, supervisor, 
             hours) %>% 
      rename("email" = "email.y", 
             "faculty" = "faculty.y", 
             "institute" = "institute.y")
    
    deakin_research_support_report_conn %>% 
      gs_edit_cells(ws = "research_support", anchor = paste0("A", lastrow+2), input = res_support_join, byrow = T,col_names = F)
    lastrow = lastrow + nrow(deakin_research_support)
    
    ## clean up
    unlink("data/", recursive = T)
    
  }
  
}



             