terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "krisking2026"
    container_name       = "tfstate"
    key                  = "terraform-project.tfstate"

  }
}

# Create Resource group 
resource "azurerm_resource_group" "hagital-rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create Vnet
resource "azurerm_virtual_network" "hagital-vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.hagital-rg.location
  resource_group_name = azurerm_resource_group.hagital-rg.name
  address_space       = ["10.0.0.0/16"]
}

# Create Subnet
resource "azurerm_subnet" "hagital-subnet" {
  name                 = var.subnet_net
  resource_group_name  = azurerm_resource_group.hagital-rg.name
  virtual_network_name = azurerm_virtual_network.hagital-vnet.name
  address_prefixes     = var.subnet_address_prefix
}

# Public Ip
resource "azurerm_public_ip" "hagital-ip" {
  name                = "hagital-ip"
  location            = azurerm_resource_group.hagital-rg.location
  resource_group_name = azurerm_resource_group.hagital-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NSG
resource "azurerm_network_security_group" "hagital-nsg" {
  name                = "hagital-nsg"
  location            = azurerm_resource_group.hagital-rg.location
  resource_group_name = azurerm_resource_group.hagital-rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
}
}
#NIC
resource "azurerm_network_interface" "hagital-nic" {
  name                = "hagital-nic"
  location            = azurerm_resource_group.hagital-rg.location
  resource_group_name = azurerm_resource_group.hagital-rg.name

  ip_configuration {
    name                          = "hagital-ipconfig"
    subnet_id                     = azurerm_subnet.hagital-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hagital-ip.id
  }
}

#Assocaite NSG with NIC
resource "azurerm_network_interface_security_group_association" "hagital-nic-nsg" {
  network_interface_id      = azurerm_network_interface.hagital-nic.id
  network_security_group_id = azurerm_network_security_group.hagital-nsg.id
}

#Linux VM
resource "azurerm_linux_virtual_machine" "hagital-vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.hagital-rg.name
  location            = azurerm_resource_group.hagital-rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.hagital-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.ssh_public_path)
  }

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

