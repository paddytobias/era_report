source("libraries.R")

gmail_auth(token = "../tokens/gmail_token.rds")

dir = "../tokens"
client_name = list.files("..", full.names = T)[grep("client_secret*", list.files("..", full.names = T))]
client = client_name %>% 
  read_json()

gmail_auth(secret_file = client_name) 

era_email ="paddy@intersect.org.au"
era_name = "pad"
report_link = "X"
month = "01"
year = 2019

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


email_out_era(era_email, era_name, report_link, month, year)


