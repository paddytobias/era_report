
dir = "tokens"


if (!dir.exists(dir)) dir.create("tokens")

token = gs_auth(key = client_id, secret = client_secret, cache = FALSE)
saveRDS(token, file = file.path(dir, "gs_token.rds"))

token = gc_auth(key = client_id, secret = client_secret, cache = FALSE)
saveRDS(token, file = file.path(dir, "gc_token.rds"))

token = gmail_auth(id = client_id, secret = client_secret)
saveRDS(token, file = file.path(dir, "gmail_token.rds"))

files = list.files()
client = files[grep("client_secret*", files)]

token = drive_auth_config(path = client)
saveRDS(token, file.path(dir, "drive_auth.rds"))

