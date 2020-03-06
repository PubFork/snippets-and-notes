# allow create and update to secrets
path "secret/data/*" {
  capabilities = ["create", "update"]
}

# lock down this secret to only read (default is deny)
path "secret/data/foo" {
  capabilities = ["read"]
}
