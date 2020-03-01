path "secret/foo" {
  capabilities = ["read"]
  mfa_methods  = ["dev_team_duo", "sales_team_totp"]
}
