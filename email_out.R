library(gmailr)
source('config.r')
args = commandArgs(trailingOnly = TRUE)

report_link = args[1]

gmail_auth(id = client_id, secret = client_secret) # authenticate for Gmail

era_email = email 

email_func = function(recipient_email, sender_email, recipient_name, report_link){
  email = mime(To = recipient_email, From = sender_email, 
               Subject = "New eRA report prepared",
               body = paste0("Hi ", recipient_name, ", A new monthly report has been created for you.\nIt can be found here: ", report_link))
  return(email)
}


if (send_to_stakeholder == FALSE & send_to_you == TRUE){
    email = email_func(era_email, era_email, eRA_name, report_link)
    send_message(email)

    message("Email sent to eRA")
} else if (send_to_you == TRUE & send_to_stakeholder==TRUE){
    
    recipients_df = as.data.frame(emails = as.character(era_email, stakeholder_email), 
                                  names = as.character(eRA_name, report_stakeholder))
    
    for (i in 1:nrow(recipients_df)){
      email = email_func(recipients_df$emails[i], era_email, recipients_df$names[i], report_link)
      send_message(email)
      message(paste("Email sent to", recipients_df$emails[i]))
    }
    
} else if (send_to_you == FALSE & email_to_stakeholder == TRUE){
    email = email_func(stakeholder_email, sender_email, report_stakeholder, report_link)
    send_message(email)
    message("Email sent to stakeholder")
}
  