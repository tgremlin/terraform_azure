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

resource "azurerm_container_group" "ncdocker" {
  name                  = "nextcloud-docker"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  ip_address_type       = "public"
  os_type               = "Linux"

  container {
    name    = "nextcloud"
    image   = "nextcloud:latest"
    cpu     = 1
    memory  = 2
    
    ports {
      port     = 80
      protocol = "TCP"     
    }
  }
}