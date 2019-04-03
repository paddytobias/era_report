# look up report authority

report_authority_id = "1G2YadcphdT1xkf6VJLiF-zvaLYd3a113avNJCMsB930"
cat_ont_id = "15xMCijYfRvZpiArEFmPPQ4-jZ-9AQBMHtvzS5kwx8IU" # for categorising eRA work ## do not touch


gs_auth(token = "../tokens/gs_token.rds") # authenticate for Google Sheets

config_data = suppressMessages(report_gs(report_authority_id) %>% 
  gs_read(ws = "config")) 

cat_ontols = suppressMessages(report_gs(cat_ont_id) %>%
  gs_read(ws = "category_codes") %>% 
  select(-Catergories) %>% 
  gather("names", "codes") %>% 
  filter(!is.na(codes)))
  
