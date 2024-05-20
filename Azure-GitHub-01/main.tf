terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.12.0"
    }
  }
}
provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "gitgrp" {
  name     = "mygitgrp"
  location = "eastus"
}

resource "azurerm_virtual_network" "gitvnet" {
  name                = "mygitvnet"
  location            = azurerm_resource_group.gitgrp.location
  resource_group_name = azurerm_resource_group.gitgrp.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "gitsubnet" {
  name                 = "mygitsubnet"
  resource_group_name  = azurerm_resource_group.gitgrp.name
  address_prefixes     = ["10.0.16.0/24"]
  virtual_network_name = azurerm_virtual_network.gitvnet.name

}

resource "azurerm_public_ip" "public_ip" {
  name                = "vm_public_ip"
  resource_group_name = azurerm_resource_group.gitgrp.name
  location            = azurerm_resource_group.gitgrp.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "gitnic" {
  name                = "mygitnic"
  location            = azurerm_resource_group.gitgrp.location
  resource_group_name = azurerm_resource_group.gitgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.gitsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}


resource "azurerm_network_security_group" "web_vmnic_nsg" {
  name                = "mygitns-nsg"
  location            = azurerm_resource_group.gitgrp.location
  resource_group_name = azurerm_resource_group.gitgrp.name
}

# Resource-2: Associate NSG and Linux VM NIC
resource "azurerm_network_interface_security_group_association" "web_vmnic_nsg_associate" {
  depends_on = [ azurerm_network_security_rule.web_vmnic_nsg_rule_inbound]  
  network_interface_id       = azurerm_network_interface.gitnic.id
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
  for_each = local.web_vmnic_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value 
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.gitgrp.name
  network_security_group_name = azurerm_network_security_group.web_vmnic_nsg.name
}



# Locals Block for custom data
locals {
  webvm_custom_data = <<CUSTOM_DATA
#!/bin/sh
# Update the system
sudo yum update -y
# Install Apache HTTP Server (httpd)
sudo yum install httpd -y
# Install Git
sudo yum install git -y
# Clone the repository
git clone https://github.com/Michaelgwei86/wanda-ecommerce-web-app.git
# Copy the files inside the cloned folder to the desired location
sudo cp -r wanda-ecommerce-web-app/server1/* /var/www/html/
# Start and enable the HTTP server
sudo systemctl start httpd
sudo systemctl enable httpd
CUSTOM_DATA  
}

resource "azurerm_linux_virtual_machine" "gitvm" {
  
  name                  = "mygitvm"
  location              = azurerm_resource_group.gitgrp.location
  resource_group_name   = azurerm_resource_group.gitgrp.name
  size                  = "Standard_DS1_v2"
  admin_username        = "azureuser"
  network_interface_ids = [ azurerm_network_interface.gitnic.id ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${path.module}/ssh-keys/terraform-azure.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "83-gen2"
    version   = "latest"
  }
  #custom_data = filebase64("${path.module}/app-scripts/redhat-webvm-script.sh")    
  custom_data = base64encode(local.webvm_custom_data)
}

