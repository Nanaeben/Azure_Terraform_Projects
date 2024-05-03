# bastionTier Subnet
resource "azurerm_subnet" "bastionsubnet" {
  name                 = "mydbsubnet"
  resource_group_name  = azurerm_resource_group.mybastionhostgrp.name
  virtual_network_name = azurerm_virtual_network.mynet.name
  address_prefixes     = ["10.0.7.0/24"]
}

# bastionTier NSG
resource "azurerm_network_security_group" "bastion_subnet_nsg" {
  name                = "bastion_subnet_nsg"
  location            = azurerm_resource_group.mybastionhostgrp.location
  resource_group_name = azurerm_resource_group.mybastionhostgrp.name

}

# Resource-3: Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "bastion_subnet_nsg_associate" {
  depends_on                = [azurerm_network_security_rule.bastion_nsg_rule_inbound] # Every NSG Rule Association will disassociate NSG from Subnet and Associate it, so we associate it only after NSG is completely created - Azure Provider Bug https://github.com/terraform-providers/terraform-provider-azurerm/issues/354  
  subnet_id                 = azurerm_subnet.bastionsubnet.id
  network_security_group_id = azurerm_network_security_group.bastion_subnet_nsg.id
}


# Resource-4: Create NSG Rules
## Locals Block for Security Rules
locals {
  bastion_inbound_ports_map = {
    "100" : "22", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "3389",
  }
}

## NSG Inbound Rule for WebTier Subnets
resource "azurerm_network_security_rule" "bastion_nsg_rule_inbound" {
  for_each                    = local.bastion_inbound_ports_map
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
  network_security_group_name = azurerm_network_security_group.bastion_subnet_nsg.name
}