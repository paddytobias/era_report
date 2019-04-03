########
# to run in command line
# a script to create weekly worksheets from google calendar events
# intended to run at the end of each month
# make sure set_up.R is run first and config.R is filled in

# e.g. run, Rscript era_report.R MM YYYY eRA@intersect.org.au
#             - MM and YYYY are placeholders for the month and year that you want to report on
########


args = commandArgs(trailingOnly = TRUE)
template_id = "17jPfpBXFyvOh0E5diaTfGJspm7LRvD4Jrv4dCXnvuh4" # do not touch
mvr_id = "1D3jSTSzrcaeCjZEZWW8jLVgxmYGrKYJPDsY6jEw1RJE" # keeping a total list of all eRA work ## do not touch
report_log_id = "14dxjfgqXMQtCx8wi3CHnm4Pd1K0urHK786-uVwnWSh4"# for keeping a history of reports produced ## do not touch


if (!dir.exists("tokens")){
  source("authing.R")
}

source("libraries.R")
source("functions.R") 
client = read_json(get_client("client_secret*"))


# authentication
gc_auth(token = "tokens/gc_token.rds") # authenticate for Google Sheets
gs_auth(token = "tokens/gs_token.rds") # authenticate for Google Cal
gmail_auth(token = "tokens/gmail_token.rds")
drive_auth(oauth_token = "tokens/drive_auth.rds") ## authenticate for Google Drive

source("report_authority.R")

# globals
month = args[1]
if (is.na(month)){
    month = format(as.Date(Sys.Date()-months(1)), "%m")
    
}

year = args[2]
if (is.na(year)){
    year = format(as.Date(Sys.Date()), "%Y")
}

email = args[3]
if (!is.na(email)){
  config_data = config_data %>% 
    filter(era_email == email)
}


for (i in 1:nrow(config_data)){
  if (config_data$prepare_report[i]==TRUE){
    
    # set configurations
    config = config_data[i,]
    member = as.character(config_data[i, "u_name"])
    if (member == "Deakin University"){
      member = paste(member, as.character(config_data[i, "era_location"]), sep = " - ")
    }
    dest_folder_id = as.character(config_data[i, "dest_folder_id"])
    era_name = as.character(config_data[i, "era_name"])
    era_email = as.character(config_data[i, "era_email"])
    u_code = as.character(config_data[i, "u_code"])
    report_stakeholder = as.character(config_data[i, "stakeholder_name"])
    stakeholder_email = as.character(config_data[i,"stakeholder_email"])
    ## first auth
    report_file_id <- copy_report(year, month, member, dest_folder_id, template_id, stakeholder_email = stakeholder_email)
    report <-  report_gs(report_file_id)
    report_monthlyReport <- report %>% gs_read(ws = "Month dashboard")
    month_weeks <- get_month_eow_dates(year, month)
    month_events <- get_month_events(era_email, year,month)
    
    table_insert_week1 <- data.frame("Hours" = as.character(), "Task" = as.character(), "Activity" = as.character(), "Description" = as.character(), "Contact" = as.character(), "Date" = as.character(), stringsAsFactors = FALSE)
    table_insert_week2 <- data.frame("Hours" = as.character(), "Task" = as.character(), "Activity" = as.character(), "Description" = as.character(), "Contact" = as.character(), "Date" = as.character(), stringsAsFactors = FALSE)
    table_insert_week3 <- data.frame("Hours" = as.character(), "Task" = as.character(), "Activity" = as.character(), "Description" = as.character(), "Contact" = as.character(), "Date" = as.character(), stringsAsFactors = FALSE)
    table_insert_week4 <- data.frame("Hours" = as.character(), "Task" = as.character(), "Activity" = as.character(), "Description" = as.character(), "Contact" = as.character(), "Date" = as.character(), stringsAsFactors = FALSE)
    table_insert_week5 <- data.frame("Hours" = as.character(), "Task" = as.character(), "Activity" = as.character(), "Description" = as.character(), "Contact" = as.character(), "Date" = as.character(), stringsAsFactors = FALSE)
    table_insert_month <- data.frame("Hours" = as.character(), "Task" = as.character(), "Activity" = as.character(), "Description" = as.character(), "Contact" = as.character(), "Date" = as.character(), stringsAsFactors = FALSE)
    
##---- for loop to create weekly work sheets and one for the month
    for (j in 1:nrow(month_events)){
      date = month_events$startDate[j]
      
      ## clean ups
      # utilising title of event
      if (grepl("\\$", month_events$summary[j])) {
        title = trimws(gsub("(.*)(:)(.*)(\\$)(.*)", "\\3", month_events$summary[j]))
      } else {
        title = trimws(gsub("(.*)(:)(.*)", "\\3", month_events$summary[j]))
      }
      
      # utilising who or "Contact"
      if (grepl("\\$", month_events$summary[j])){
        who = gsub("(.*)(\\$)(.*)", "\\3", month_events$summary[j])
      } else if (month_events$organizer.self[j] == FALSE) {
        who = month_events$organizer.displayName[j]
      } else {
        who = "NA"
      }
      
##---- categorising calendar events
      if (grepl("\\:", month_events$summary[j])){
        tag = gsub("(.*)(\\:)(.*)", "\\1", month_events$summary[j])
      } else {
        tag = "untagged"
      }
      
      if (!(tag %in% cat_ontols$codes)){ ## controlling the vocab
        tag = "tag not correct"
      } else {
        ## standardising and prettifying tag names
        tag = cat_ontols %>% 
          filter(grepl(paste0("^",tag,"$"), codes, ignore.case=T)) %>% 
          select(names) %>% 
          as.character()
      }
      
##---- cleaning up common long-winded descriptions
      is_zoom_meeting = grepl("zoom.us", month_events$description[j])
      is_training = grepl("Course Materials", month_events$description[j])
      if(is_zoom_meeting) {
        description = "Video conference"
      } else if (is_training) {
        description = "Training"
      } else {
        description = month_events$description[j]
      }
########
      
      minutes = month_events$hours_long[j]
      hours = (as.numeric(minutes)%/%60 +  (as.numeric(minutes)%%60/60))
      
      input = cbind(hours, 
                    title,
                    tag,
                    description,
                    who, 
                    date)
      input = data.frame(input, stringsAsFactors = FALSE)
      
      ## catch events that are all day Personal Leave and assign 7.5 hours
      if (is.na(input$hours) & input$tag=="Personal"){
        input$hours=7.5
      }
        
      # build month events
      names(input) = names(table_insert_month)
      table_insert_month = rbind(table_insert_month, input)
      names(table_insert_month) = c("Hours", "Task", "Activity", "Description", "Contact", "Date")
      
      if (date <= as.Date(as.character(month_weeks[1,1]), "%Y-%m-%d")){
        names(input) = names(table_insert_week1)
        table_insert_week1 = rbind(table_insert_week1, input)
        names(table_insert_week1) = c("Hours", "Task", "Activity", "Description", "Contact", "Date")
        
      } else if (date > as.Date(as.character(month_weeks[1,1]), "%Y-%m-%d") & date <= as.Date(as.character(month_weeks[2,1]), "%Y-%m-%d")){
        names(input) = names(table_insert_week2)
        table_insert_week2 = rbind(table_insert_week2, input)
        names(table_insert_week1) = c("Hours", "Task", "Activity", "Description", "Contact", "Date")
        
      } else if (date > as.Date(as.character(month_weeks[2,1]), "%Y-%m-%d") & date <= as.Date(as.character(month_weeks[3,1]), "%Y-%m-%d")){
        names(input) = names(table_insert_week3)
        table_insert_week3 = rbind(table_insert_week3, input)
        names(table_insert_week1) = c("Hours", "Task", "Activity", "Description", "Contact", "Date")
        
      } else if (date > as.Date(as.character(month_weeks[3,1]), "%Y-%m-%d") & date <= as.Date(as.character(month_weeks[4,1]), "%Y-%m-%d")){
        names(input) = names(table_insert_week4)
        table_insert_week4 = rbind(table_insert_week4, input)
        names(table_insert_week1) = c("Hours", "Task", "Activity", "Description", "Contact", "Date")
        
      } else if (date > as.Date(as.character(month_weeks[4,1]), "%Y-%m-%d") & date <= as.Date(as.character(month_weeks[5,1]), "%Y-%m-%d")){
        names(input) = names(table_insert_week5)
        table_insert_week5 = rbind(table_insert_week5, input)
        names(table_insert_week1) = c("Hours", "Task", "Activity", "Description", "Contact", "Date")
        
      }
    }
    
    
    insert_weekly_tables(month_weeks, 
                         table_insert_week1, 
                         table_insert_week2, 
                         table_insert_week3, 
                         table_insert_week4, 
                         table_insert_week5,
                         table_insert_month)
    
    # insert report details on front page
    report_details = rbind(report_stakeholder, member, era_name)
    report %>% 
      gs_edit_cells(ws = "Month dashboard", input = report_details, anchor = "B2", byrow = TRUE, col_names = FALSE)
    
    report_link = report$browser_url
    print(paste("Report saved to", report_link))
    
    # save information to report log
    report_details = data.frame("year" = as.character(year), 
                                "month" = as.character(month), 
                                "member" = as.character(member), 
                                "era" = as.character(era_email), 
                                "link" = report_link)
    
    report_log_conn = report_gs(report_log_id)
    
    report_log = report_log_conn %>% 
      gs_read(ws = "log")
    
    isnt.present = !( report_link %in% report_log$link) ## check if report has been produced before.
    if (isnt.present){
      report_log_nrow = nrow(report_log)
      
      report_log_conn %>% 
        gs_edit_cells(ws = "log", anchor = paste0("A", report_log_nrow+2), input = report_details, col_names = F, byrow = T)
    } else {
      base::message("details already logged")
    }
    
    base::message("About to send email")
    # sending era report email notifications
    email_out_era(era_email, era_name, report_link, month, year)
    base::message("Email sent to eRA")
    
  }
  
}


