data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  common_tags = {
    ManagedBy   = "Terraform"
    Env = var.env
    Owner       = var.owner
    CostCenter  = var.cost_center
  }
}