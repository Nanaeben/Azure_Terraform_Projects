# Create Virtual Network

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.resource_name_prefix}-${var.vnet_name}"
  address_space       = var.app_subnet_address
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tag
}
