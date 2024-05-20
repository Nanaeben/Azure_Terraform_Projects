terraform {
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = "3.12.0"
      }
    }
}

provider "azurerm" {
  features {
    
  }
}

locals {
  owners               = "orlab"
  environment          = "env"
  resource_name_prefix = "res"
  #name = "${local.owners}-${local.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
} 

resource "random_string" "myrandom" {
  length  = 6
  upper   = false
  special = false
  numeric = false
}

#CREATE RESOURCE GROUP
resource "azurerm_resource_group" "multigrp" {
  name = "${local.resource_name_prefix}-${random_string.myrandom.id}-mymultigrp"
  location = "eastus"
}

#CREATE MAIN VNET
resource "azurerm_virtual_network" "myvnet" {
  name = "mymainvnet"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.multigrp.location
  resource_group_name = azurerm_resource_group.multigrp.name
}

#CREATE A SUBNET
resource "azurerm_subnet" "test" {
  name = "mysubnet"
  resource_group_name = azurerm_resource_group.multigrp.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes = ["10.0.16.0/24"]
}

# CREATE PUBLIC IP
resource "azurerm_public_ip" "testip" {
  name = "PublicIPForLB"
  location = azurerm_resource_group.multigrp.location
  resource_group_name = azurerm_resource_group.multigrp.name
  allocation_method = "Static"
}

# CREATE LOAD BALANCER
resource "azurerm_lb" "mainlb" {
  name = "loadBalancer"
  location = azurerm_resource_group.multigrp.location
  resource_group_name = azurerm_resource_group.multigrp.name

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.testip.id
  }
}

# CREATE BACKEND POOL
resource "azurerm_lb_backend_address_pool" "testpool" {
  loadbalancer_id = azurerm_lb.mainlb.id
  name = "BackEndAddressPool"
}

#CREATE NIC
resource "azurerm_network_interface" "test" {
  count = 3
  name = "${local.resource_name_prefix}acctnic${count.index}"
  location = azurerm_resource_group.multigrp.location
  resource_group_name = azurerm_resource_group.multigrp.name

  ip_configuration {
    name = "testConfiguration"
    subnet_id = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}


#CREATE STORAGE DISK
resource "azurerm_managed_disk" "test" {
  count = 3
  name = "datadisk_${count.index}"
  location = azurerm_resource_group.multigrp.location
  resource_group_name = azurerm_resource_group.multigrp.name
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = "100"
}

#CREATE AVAILABILITY SET
resource "azurerm_availability_set" "avset" {
  name = "avset"
  location = azurerm_resource_group.multigrp.location
  resource_group_name = azurerm_resource_group.multigrp.name
  platform_fault_domain_count = 2
  platform_update_domain_count = 8
  managed = true
}

#CREATE VMs
# resource "azurerm_linux_virtual_machine" "web_linuxvm" {
#   count = 8
#   name = "${local.resource_name_prefix}-${random_string.myrandom.id}-orlvm${count.index}"
#   location = azurerm_resource_group.multigrp.location
#   resource_group_name = azurerm_resource_group.multigrp.name
#   availability_set_id = azurerm_availability_set.avset.id
#   network_interface_ids = [element(azurerm_network_interface.test.*.id, count.index)]
#   size = "Standard_DS1_V2"
#   admin_username = "azureuser"
#   admin_ssh_key {
#     username = "azureuser"
#     public_key = file("${path.module}/ssh-keys/terraform-azure.pub")
#   }

#   source_image_reference {
#     publisher = "Cononical"
#     offer = "UbuntuServer"
#     sku = "22.04-LTS"
#     version = "lastest"
#   }

 
#    os_disk {
#     caching = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   tags = {
#     environment = "staging"
#   }


# }

resource "azurerm_virtual_machine" "example" {
  count               = 3
  name                = "example-vm-${count.index}"
  location            = azurerm_resource_group.multigrp.location
  resource_group_name = azurerm_resource_group.multigrp.name
  network_interface_ids = [azurerm_network_interface.test[count.index].id]

  vm_size                  = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "hostname-${count.index}"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}