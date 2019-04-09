library(jsonlite)
library(googlesheets)

dir = "tokens"
client_name = list.files()[grep("client_secret*", list.files())]
client = read_json(client_name) 

## create folder for tokens to be placed in (if it doesn't exist)
if (!dir.exists(dir)) dir.create(dir)

token = gs_auth(key = client$installed$client_id, 
                secret = client$installed$client_secret, 
                cache = FALSE)
saveRDS(token, file = file.path(dir, "gs_token.rds"))
