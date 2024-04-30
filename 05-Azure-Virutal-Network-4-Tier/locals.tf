# Define Local Variable

locals {
  owners               = var.business_division
  environment          = var.environment
  resource_name_prefix = "${var.business_division}-${var.environment}"
  common_tag = {
    owners      = local.owners,
    environment = local.environment
  }
}