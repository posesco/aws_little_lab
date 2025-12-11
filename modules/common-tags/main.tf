locals {
  base_tags = {
    ManagedBy   = "Terraform"
    Owner       = "posesco"
    Environment = var.env
    Project     = var.project
  }
  optional_tags = var.additional_tags != null ? var.additional_tags : {}
  all_tags      = merge(local.base_tags, local.optional_tags)
}
