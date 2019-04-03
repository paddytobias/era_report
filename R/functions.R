source("libraries.R")
client = list.files()[grep("client_secret*", list.files())]


gc_auth(token = "tokens/gc_token.rds") # authenticate for Google Sheets
gs_auth(token = "tokens/gs_token.rds") # authenticate for Google Cal
gmail_auth(secret_file = client)
drive_auth(oauth_token = "tokens/drive_auth.rds")


# functions
copy_report = function(year, month, member, dest_folder_id, template_id, stakeholder_email){
  month_name = month.abb[as.numeric(month)]
  report_name <- paste0(month_name, year, "_eRA-report_", member)
  folder_contents = drive_ls(as_id(dest_folder_id))
  if (report_name %in% folder_contents$name){ # check if report already exists and handle as appropriate
    existing_report_ids = folder_contents %>% filter(name==report_name) %>% select(id)
    if (nrow(existing_report_ids) > 1){
      for (id in existing_report_ids$id[-1]){
        drive_mv(as_id(id), name = paste0(report_name, "_OLD"))
      }
      
    }
    return(existing_report_ids$id[1])
    
  } else { # else if report doesn't exist copy from template
    file = drive_cp(as_id(template_id), path = as_id(dest_folder_id), name = report_name)
    file_id = file$id
    drive_share(as_id(file_id),role = "reader", type = "anyone") # anyone will be able to see this report with the link
    # could use the following for assigning permissions ONLY to stakeholder, but this would require them to have a Google account and for use to be using this account to share to
    # drive_share(as_id(file_id),role = "reader", type = "user", emailAddress = stakeholder_email)
    return(file_id)
    
  }
  
}

##---- to dynamically set globals for the month being reported
get_month_start_dates = function(year, month){
  start_month = as.Date(paste(year, month, "01", sep = "-"))
  if(month == "12"){
    start_next_month = paste(as.numeric(year)+1, "01", "01", sep = "-")
  } else {
    start_next_month = paste(year, as.numeric(month)+1, "01", sep = "-")
  }
  end_month = as.Date(start_next_month) - 1
  
  return(data.frame("start_month" = as.character(start_month), 
                    "start_next_month" = as.character(start_next_month), 
                    "end_month" = as.character(end_month), stringsAsFactors = F))
}

get_month_eow_dates = function(year, month){
  month_first_day = paste(year,month, "01", sep='-')
  month_dates = data.frame(dates = as.Date(seq.Date(from = as.Date(month_first_day), by = "day", length.out = 31)))
  eow_dates = data.frame(eow_dates = as.character(), stringsAsFactors = FALSE)
  for (i in 1:nrow(month_dates)){
    if (weekdays(as.Date(month_dates[i,1])) == "Friday"){
      eow_dates = rbind(eow_dates, as.character(month_dates[i,1]), stringsAsFactors = FALSE)
      
    }
  }
  eow_dates = rbind(eow_dates, as.character(Sys.Date()), stringsAsFactors = FALSE)
  names(eow_dates) = "eow_dates"
  return(eow_dates)
}


##---- to return dataframe for calendar events of the month
get_events = function(email_add, year, month){
  month_start_dates = get_month_start_dates(year, month)
  
  events = gc_id(email_add)
  if (!is.null(events)){
    events = events %>%
      gc_event_ls(params = paste0("maxResults=5000&timeMin=", month_start_dates$start_month, "T00:00:00+11:00&timeMax=", month_start_dates$start_next_month, "T00:00:00+11:00")) %>%
      mutate(startDate = paste(start.date, start.dateTime), endDate = paste(end.date, end.dateTime),
             startTime = gsub("[0-9]{4}-[0-9]{2}-[0-9]{2}T|\\+[0-9]{2}:[0-9]{2}", "", start.dateTime),
             endTime = gsub("[0-9]{4}-[0-9]{2}-[0-9]{2}T|\\+[0-9]{2}:[0-9]{2}", "", end.dateTime))#%>% filter(start.date>Sys.Date()-20)
    
    events$startDate = trimws(gsub("(NA)", "", events$startDate))
    events$endDate = trimws(gsub("NA", "", events$endDate))
    
    events$startDate = trimws(gsub("T[0-9]{2}:[0-9]{2}:[0-9]{2}\\+[0-9]{2}:[0-9]{2}", "", events$startDate))
    events$endDate = trimws(gsub("T[0-9]{2}:[0-9]{2}:[0-9]{2}\\+[0-9]{2}:[0-9]{2}", "", events$endDate))
    
    return(events[with(events, order(as.Date(startDate), as.Date(endDate))),])
  } else {
    print(paste("Calendar for", email_add, "not found"))
    next
  }
  
}

get_month_events = function(era_email, year, month){
  events = get_events(era_email, year, month)
  
  month_start_dates = get_month_start_dates(year, month)

  month_events = events %>%
    filter(startDate > month_start_dates$start_month & startDate < month_start_dates$end_month) %>% 
    arrange(desc(as.Date(startDate)))
  #add hours column
  month_events$hours_long = round(difftime(as.POSIXct(month_events$end.dateTime,format="%Y-%m-%dT%H:%M:%S"), as.POSIXct(month_events$start.dateTime,format="%Y-%m-%dT%H:%M:%S"), units = "mins"),2)
  return(month_events)
}

## connect with google sheet 
report_gs = function(report_file_id){
  report <- gs_key(as_id(report_file_id))
}

## getting collapsing events with the same title into one with total hours work
table_clean_up = function(table){
  locs_to_remove = NULL
  for (i in 1:nrow(table)){
    print(i)
    if (length(grep(table$Task[i], table$Task)) > 1){
      locs = grep(table$Task[i], table$Task)
      subset = table[locs,]
      sum_hours = sum(as.numeric(subset$`Hours`))
      table$`Hours`[i]=sum_hours
      # create date range when the same event is done over different dates
      if (as.Date(subset$Date[1])!=as.Date(tail(subset$Date, 1))){
        date_range = paste(subset$Date[1], tail(subset$Date, 1), sep = "-")
        table$Date[i]=date_range
      }
      remove_locs = tail(locs, length(locs)-1)
      locs_to_remove = c(locs_to_remove, remove_locs)
    }
  }
  if (!is.null(locs_to_remove)){
    table = table[-c(locs_to_remove),]
  }
  
  return(table)
}

top_10_projects = function(){
  # return a list of top 10 projects by Hours
  weeks_combined = rbind(table_insert_week1, table_insert_week2, table_insert_week3, table_insert_week4, table_insert_week5)
  weeks_combined = aggregate(as.numeric(weeks_combined$`Hours`), list(weeks_combined$Task, weeks_combined$Tag), sum)
  weeks_combined = weeks_combined[order(weeks_combined$x, decreasing = TRUE),]
  names(weeks_combined) = c("activities", "tag", "hours")
  weeks_combined = data.frame(weeks_combined$activities, weeks_combined$tag, weeks_combined$hours)
  return(head(weeks_combined, 10))
}

top_20_projects = function(){
  # return a list of top 10 projects by Hours
  weeks_combined = rbind(table_insert_week1, table_insert_week2, table_insert_week3, table_insert_week4, table_insert_week5)
  weeks_combined = aggregate(as.numeric(weeks_combined$`Hours`), list(weeks_combined$Task, weeks_combined$Activity), sum)
  weeks_combined = weeks_combined[order(weeks_combined$x, decreasing = TRUE),]
  names(weeks_combined) = c("task", "activity", "hours")
  weeks_combined = data.frame(weeks_combined$task, weeks_combined$activity, weeks_combined$hours)
  return(head(weeks_combined, 20))
}

insert_weekly_tables = function(month_weeks, table_insert_week1, table_insert_week2, table_insert_week3, table_insert_week4, table_insert_week5, table_insert_month){
  #insert eow dates in Monthly report sheet
  report %>% gs_edit_cells(ws = "look_ups", input = month_weeks, anchor = "D2", byrow = TRUE, col_names = FALSE, verbose = F)
  
  #insert top 10 projects in Monthly report sheet
  top_20_projects = top_20_projects()
  report %>% gs_edit_cells(ws = "Top 20 activities", input = top_20_projects, anchor = "B4", byrow = TRUE, col_names = FALSE, verbose = F)
  
  #insert weekly sheets to Google
  anchor = "A4"
  
  worksheet = "Week 1"
  if (nrow(table_insert_week1)!=0){
    table_insert_week1 = table_clean_up(table_insert_week1)
    table_insert_week1 = table_insert_week1[,c(6,1:5)]
    report %>% gs_edit_cells(ws = worksheet, input = table_insert_week1, anchor = anchor, byrow = TRUE, verbose = F)
  }
  worksheet = "Week 2"
  if (nrow(table_insert_week2)!=0){
    table_insert_week2 = table_clean_up(table_insert_week2)
    table_insert_week2 = table_insert_week2[,c(6,1:5)]
    report %>% gs_edit_cells(ws = worksheet, input = table_insert_week2, anchor = anchor, byrow = TRUE, verbose = F)
  }
  worksheet = "Week 3"
  if (nrow(table_insert_week3)!=0){
    table_insert_week3 = table_clean_up(table_insert_week3)
    table_insert_week3 = table_insert_week3[,c(6,1:5)]
    report %>% gs_edit_cells(ws = worksheet, input = table_insert_week3, anchor = anchor, byrow = TRUE, verbose = F)
  }
  
  worksheet = "Week 4"
  if (nrow(table_insert_week4)!=0){
    table_insert_week4 = table_clean_up(table_insert_week4)
    table_insert_week4 = table_insert_week4[,c(6,1:5)]
    report %>% gs_edit_cells(ws = worksheet, input = table_insert_week4, anchor = anchor, byrow = TRUE, verbose = F)
  }
  
  worksheet = "Week 5"
  if (nrow(table_insert_week5)!=0){
    table_insert_week5 = table_clean_up(table_insert_week5)
    table_insert_week5 = table_insert_week5[,c(6,1:5)]
    report %>% gs_edit_cells(ws = worksheet, input = table_insert_week5, anchor = anchor, byrow = TRUE, verbose = F)
  }
  
  worksheet = "All month events"
  if (nrow(table_insert_month)!=0){
    table_insert_month = table_clean_up(table_insert_month)
    table_insert_month = table_insert_month[,c(6,1:5)]
    report %>% gs_edit_cells(ws = worksheet, input = table_insert_month, anchor = anchor, byrow = TRUE, verbose = F)
  }
}


email_func = function(recipient_email, sender_email, recipient_name, report_link, month, year){
  month_friendly = format(as.Date(paste(1, month, year, sep = "-"), "%d-%m-%Y"), "%B %Y")
  email = mime(To = recipient_email, From = sender_email, 
               Subject = paste("New eRA report for", month_friendly),
                body = paste0("Hi ", recipient_name, ", 

Your monthly report for ", month_friendly, " has been created for you.

It can be found here: ", report_link, "

Please review and consider sending onto your university stakeholder 

Have a nice day!"))
  return(email)
}

email_out_era = function(era_email, era_name, report_link, month, year){
  email = email_func(era_email, era_email, era_name, report_link, month, year)
  safe_send = safely(send_message)
  email %>% safe_send
}


get_client = function(pattern){
  list.files()[grep(pattern, list.files())]
}
