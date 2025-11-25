locals {
  common_tags = {
    ManagedBy = "Terraform"
    Env       = var.env
    Owner     = var.owner
    Component = "shared-networking"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}