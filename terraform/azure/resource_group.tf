resource "azurerm_resource_group" "westus" {
  name     = "fooResourceGroup"
  location = "West US"

  tags = {
    environment = "Dev"
  }
}
