# Random Provider

resource "random_string" "myrandom" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}