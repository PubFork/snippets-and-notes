# provider with managerd service identity: https://www.terraform.io/docs/providers/azurerm/guides/managed_service_identity.html
provider "azurerm" {
  version = "~> 1.43.0"
  use_msi = true # msi

  backend "azurerm" {
    resource_group_name  = "tfResourceGroup" # cli or sp
    storage_account_name = "abcd1234"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    subscription_id      = "00000000-0000-0000-0000-000000000000"
    tenant_id            = "00000000-0000-0000-0000-000000000000"
  }
}
# apply delete lock to storage account
# iam restrictions

# https://www.terraform.io/docs/providers/azurerm/guides/azure_cli.html
# https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html
