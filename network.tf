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

