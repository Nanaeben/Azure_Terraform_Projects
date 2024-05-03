# Create Virtual Nets, Subnets and VMs

resource "azurerm_virtual_network" "mynet" {
  name                = "myvnet-1"
  location            = azurerm_resource_group.mybastionhostgrp.location
  resource_group_name = azurerm_resource_group.mybastionhostgrp.name
  address_space       = ["10.0.0.0/16"]
}

# WebTier Subnet
resource "azurerm_subnet" "websubnet" {
  name                 = "mywebsubnet"
  resource_group_name  = azurerm_resource_group.mybastionhostgrp.name
  virtual_network_name = azurerm_virtual_network.mynet.name
  address_prefixes     = ["10.0.4.0/24"]
}

# WebTier NSG
resource "azurerm_network_security_group" "web_subnet_nsg" {
  name                = "web_subnet_nsg"
  location            = azurerm_resource_group.mybastionhostgrp.location
  resource_group_name = azurerm_resource_group.mybastionhostgrp.name

}

# Resource-3: Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "web_subnet_nsg_associate" {
  depends_on                = [azurerm_network_security_rule.web_nsg_rule_inbound] # Every NSG Rule Association will disassociate NSG from Subnet and Associate it, so we associate it only after NSG is completely created - Azure Provider Bug https://github.com/terraform-providers/terraform-provider-azurerm/issues/354  
  subnet_id                 = azurerm_subnet.websubnet.id
  network_security_group_id = azurerm_network_security_group.web_subnet_nsg.id
}


# Resource-4: Create NSG Rules
## Locals Block for Security Rules
locals {
  web_inbound_ports_map = {
    "100" : "80", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "443",
    "120" : "22"
  }
}

## NSG Inbound Rule for WebTier Subnets
resource "azurerm_network_security_rule" "web_nsg_rule_inbound" {
  for_each                    = local.web_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.mybastionhostgrp.name
  network_security_group_name = azurerm_network_security_group.web_subnet_nsg.name
}



# Resource-1: Create Public IP Address
/*resource "azurerm_public_ip" "web_linuxvm_publicip" {
  name                = "-web-linuxvm-publicip"
  resource_group_name = azurerm_resource_group.mybastionhostgrp.name
  location            = azurerm_resource_group.mybastionhostgrp.location
  allocation_method   = "Static"
  sku                 = "Standard"
}*/

# Resource-2: Create Network Interface
resource "azurerm_network_interface" "web_linuxvm_nic" {
  name                = "myweb-linuxvm-nic"
  location            = azurerm_resource_group.mybastionhostgrp.location
  resource_group_name = azurerm_resource_group.mybastionhostgrp.name

  ip_configuration {
    name                          = "web-linuxvm-ip-1"
    subnet_id                     = azurerm_subnet.websubnet.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id = azurerm_public_ip.web_linuxvm_publicip.id 
  }
}