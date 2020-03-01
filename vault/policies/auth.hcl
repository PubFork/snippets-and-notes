path "auth/approle/role/my=role/secret-id" {
  capabilities = ["create", "update"]
  min_wrapping_ttl = "1s" # minimum allowed TTL that clients can specify for a wrapped response
  max_wrapping_ttl = "90s" # maximum allowed TTL that clients can specify for a wrapped response
}
