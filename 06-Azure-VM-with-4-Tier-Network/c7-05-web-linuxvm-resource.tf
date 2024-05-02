# Resource: Azure Linux Virtual Machine

resource "azurerm_linux_virtual_machine" "web_linuxvm" {
  name                  = "orl-web-linux"
  computer_name         = "web-linux-vm"
  resource_group_name   = azurerm_resource_group.myrg1.name
  location              = azurerm_resource_group.myrg1.location
  size                  = "Standard_DS1_v2"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.web_linuxvm_nic.id]
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${path.module}/ssh_key/terraform-azure.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "RedHat"
    offer = "RHEL"
    sku = "83-gen2"
    version = "latest"
  }
  custom_data = filebase64("${path.module}/appscripts/webvm-scripts.sh")

}