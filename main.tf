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

resource "azurerm_storage_container" "container" {
  name                  = "nc-blob"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob"
}

resource "azurerm_virtual_network" "private_network" {
  name              = "NC-Private"
  address_space     = ["10.0.0.0/16"]
  location          = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "public-ip" {
  name                    = "nc-public-ip"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

resource "azurerm_subnet" "subnet" {
  name                  = "ncprivate"
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_name  = azurerm_virtual_network.private_network.name
  address_prefixes        = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                  = "ubuntu-nic"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ip.id
  }
}

resource "azurerm_network_security_group" "ncng" {
  name                = "nc-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                        = "port8080"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    destination_port_range      = "80"
  }

  security_rule {
    name                        = "port443"
    priority                    = 110
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    destination_port_range      = "443"
  }
}


resource "azurerm_linux_virtual_machine" "nc-ubuntu" {
  name                        = "nextcloud-server"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  size                        = "Standard_B1ms"
  admin_username              = "ncadmin"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username = "ncadmin"
    public_key = file("./secrets/ubuntu_ssh.pub")
  }

  os_disk {
    caching               = "ReadWrite"
    storage_account_type  = "Standard_LRS"
  }

  source_image_reference {
    publisher     = "Canonical"
    offer         = "UbuntuServer"
    sku           = "18.04-LTS"
    version       = "latest"
  }
}

resource "azurerm_sql_server" "mysql" {
  name                = "nc-mssqlserver"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "12.0"
  administrator_login           = "ncadmin"
  administrator_login_password  = var.sql_administrator_login_password

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.storage.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.storage.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }
}


data "azurerm_public_ip" "nc-public-ip" {
  name                = azurerm_public_ip.public-ip.name
  resource_group_name = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = data.azurerm_public_ip.nc-public-ip.ip_address
}







