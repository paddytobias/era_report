source("libraries.R")

dir = "../tokens"
client_name = list.files("..", full.names = T)[grep("client_secret*", list.files("..", full.names = T))]
client = client_name %>% 
  read_json()



## create folder for tokens to be placed in (if it doesn't exist)
if (!dir.exists(dir)) dir.create(dir)

token = gs_auth(key = client$installed$client_id, secret = client$installed$client_secret, cache = FALSE)
saveRDS(token, file = file.path(dir, "gs_token.rds"))

token = gc_auth(key = client$installed$client_id, secret = client$installed$client_secret, cache = FALSE)
saveRDS(token, file = file.path(dir, "gc_token.rds"))

token = gmail_auth(id = client$installed$client_id, secret = client$installed$client_secret)
saveRDS(token, file = file.path(dir, "gmail_token.rds"))

token = drive_auth()
saveRDS(token, file.path(dir, "drive_auth.rds"))

