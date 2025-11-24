locals {
  common_tags = {
    ManagedBy   = "Terraform"
    Environment = var.environment
    Owner       = var.lab_owner
    Component   = "shared-networking"
  }
}

