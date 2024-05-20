terraform {
  backend "azurerm" {
    resource_group_name  = "mydemo-resources"
    storage_account_name = "orlabdevopsmain"
    container_name       = "prod-tfstate"
    key                  = "prod.terraform.tfstate"
  }
}