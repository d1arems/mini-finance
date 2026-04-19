resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Network Setup
resource "azurerm_virtual_network" "main" {
  name                = "vnet-devops"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "snet-internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

#Network Security Group
resource "azurerm_network_security_group" "ssh_access" {
  name                = "nsg-ssh-allow"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" # In production, change this to your home IP!
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*" # In production, change this to your home IP!
    destination_address_prefix = "*"
  }

}

# Network Interfaces (One for each role)
resource "azurerm_network_interface" "main" {
  name                = "nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

#Public IP Address
resource "azurerm_public_ip" "main" {
  name                = "pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"   # Standard SKU requires Static allocation
  sku                 = "Standard"
  sku_tier            = "Regional"
}

#NIC and Security Group Association
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.ssh_access.id
}

# The 4 Ubuntu 22.04 VMs
resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B2as_v2"
  admin_username      = "adminuser"

  # Using SSH keys in the nodes
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa_ansible.pub")
  }

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
