
source("libraries.R")
source("report_authority.R")
source("functions.R")
source("config_dev.r")


args = commandArgs(trailingOnly = TRUE)

report_link = args[1]
era = args[2]

config = config_data %>% 
  filter(era_email==era)

member = as.character(config["u_name"])
if (member == "Deakin University"){
  member = paste(member, as.character(config["era_location"]), sep = " - ")
}
dest_folder_id = as.character(config["dest_folder_id"])
eRA_name = as.character(config$era_name)

gmail_auth(id = client_id, secret = client_secret) # authenticate for Gmail

#era_email = email 




if (config$send_to_stakeholder == FALSE & config$send_to_you == TRUE){
    email = email_func(era, era, eRA_name, report_link)
    send_message(email)

    message("Email sent to eRA")
} else if (config$send_to_you == TRUE & config$send_to_stakeholder==TRUE){
    
    recipients_df = as.data.frame(emails = as.character(era_email, stakeholder_email), 
                                  names = as.character(eRA_name, report_stakeholder))
    
    for (i in 1:nrow(recipients_df)){
      email = email_func(recipients_df$emails[i], era_email, recipients_df$names[i], report_link)
      send_message(email)
      message(paste("Email sent to", recipients_df$emails[i]))
    }
    
} else if (config$send_to_you == FALSE & config$email_to_stakeholder == TRUE){
    email = email_func(stakeholder_email, sender_email, report_stakeholder, report_link)
    send_message(email)
    message("Email sent to stakeholder")
}
  