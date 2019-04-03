

mvr_id = "1D3jSTSzrcaeCjZEZWW8jLVgxmYGrKYJPDsY6jEw1RJE"

mvr_data = report_gs(mvr_id) 

mvr_input = table_insert_month[c("Date", "Hours", "Task", "Activity")]

mvr_era_activities = mvr_data %>% 
  gs_read(ws = "era_activities")

mvr_input = rbind(mvr_era_activities, mvr_input)

mvr_data %>% 
  gs_edit_cells(ws = "era_activities", input = mvr_input, anchor = "A2", byrow = TRUE, col_names = FALSE)
