path "transit/keys/my_app_key" {
  capabilities = ["read"]
}

path "transit/rewrap/my_app_key" {
  capabilities = ["update"]
}

# needed to seed the database as part of the example
path "transit/encrypt/my_app_key" {
  capabilities = ["update"]
}
