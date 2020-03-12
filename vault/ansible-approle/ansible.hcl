path "secret/data/org/" {
  capabilities = ["list"]
}

path "secret/data/org/*" {
  capabilities = ["read", "list"]
}
