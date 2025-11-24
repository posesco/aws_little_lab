data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  common_tags = {
    ManagedBy   = "Terraform"
    Environment = var.environment
    Owner       = var.lab_owner
    CostCenter  = var.cost_center
  }
}

