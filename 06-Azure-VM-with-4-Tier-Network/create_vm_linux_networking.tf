# Terraform Block

terraform {
  required_version = ">= 1.8"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}


#Provider Block
provider "azurerm" {
  features {}
}


# Resource Group
resource "azurerm_resource_group" "myrg1" {
  name     = "myvmgrp"
  location = "eastus"
}

# Resource-1: Create Public IP Address
resource "azurerm_public_ip" "web_linuxvm_publicip" {
  name                = "mypublicip"
  resource_group_name = azurerm_resource_group.myrg1.name
  location            = azurerm_resource_group.myrg1.location
  allocation_method   = "Static"
  sku                 = "Standard"
  #domain_name_label = "app1-vm-${random_string.myrandom.id}"
}

# Virtual Network
resource "azurerm_virtual_network" "myvnet2" {
  name                = "myvnet-2"
  resource_group_name = azurerm_resource_group.myrg1.name
  location            = azurerm_resource_group.myrg1.location
  address_space       = ["10.0.0.0/16"]

}

# CREATING SUBNETS
resource "azurerm_subnet" "websubnet" {
  name                 = "websubnet"
  address_prefixes     = ["10.0.15.0/24"]
  resource_group_name  = azurerm_resource_group.myrg1.name
  virtual_network_name = azurerm_virtual_network.myvnet2.name

}

# Resource-2: Create Network Interface
resource "azurerm_network_interface" "web_linuxvm_nic" {
  name                = "myvnic"
  location            = azurerm_resource_group.myrg1.location
  resource_group_name = azurerm_resource_group.myrg1.name

  ip_configuration {
    name                          = "web-linuxvm-ip-1"
    subnet_id                     = azurerm_subnet.websubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_linuxvm_publicip.id
  }
}

# Resource-3 (Optional): Create Network Security Group and Associate to Linux VM Network Interface
# Resource-1: Create Network Security Group (NSG)
resource "azurerm_network_security_group" "web_vmnic_nsg" {
  name                = "mynsg"
  location            = azurerm_resource_group.myrg1.location
  resource_group_name = azurerm_resource_group.myrg1.name
}

# Resource-2: Associate NSG and Linux VM NIC
resource "azurerm_network_interface_security_group_association" "web_vmnic_nsg_associate" {
  depends_on                = [azurerm_network_security_rule.web_vmnic_nsg_rule_inbound]
  network_interface_id      = azurerm_network_interface.web_linuxvm_nic.id
  network_security_group_id = azurerm_network_security_group.web_vmnic_nsg.id
}

# Resource-3: Create NSG Rules
## Locals Block for Security Rules
locals {
  web_vmnic_inbound_ports_map = {
    "100" : "80", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "443",
    "120" : "22"
  }
}
## NSG Inbound Rule for WebTier Subnets
resource "azurerm_network_security_rule" "web_vmnic_nsg_rule_inbound" {
  for_each                    = local.web_vmnic_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myrg1.name
  network_security_group_name = azurerm_network_security_group.web_vmnic_nsg.name
}