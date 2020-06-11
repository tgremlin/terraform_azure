provider "azurerm" {
    version = "=2.12.0"
features {
    
}
}

resource "azurerm_resource_group" "rg" {
    name     = "NextCloud"
    location = "eastus"
tags = {
    name = "NextCloud"
}
}

data "azurerm_public_ip" "nc-public-ip" {
  name                = azurerm_public_ip.public-ip.name
  resource_group_name = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = data.azurerm_public_ip.nc-public-ip.ip_address
}







