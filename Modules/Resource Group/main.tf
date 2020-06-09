resource "azurerm_resource_group" "rg" {
    name     = "NextCloud"
    location = "eastus"
tags = {
    name = "NextCloud"
}
}

output "id" {
  value = azurerm_resource_group.rg.id
}

