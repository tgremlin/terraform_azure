provider "azurerm" {
    version = "=2.0.0"
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

resource "azurerm_storage_account" "storage" {
  name                      = "nextcloudstorage"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  
  tags = {
      environment = "Devlopment"
  }
}

resource "azurerm_virtual_network" "private_network" {
  name              = "NC-Private"
  address_space     = ["10.0.0.0/16"]
  location          = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
}


