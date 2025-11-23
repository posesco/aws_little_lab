locals {
  common_tags = merge(
    {
      ManagedBy   = "Terraform"
      Environment = var.environment
      Project     = var.project_name
      Owner       = var.owner
      CostCenter  = var.cost_center
      CreatedAt   = timestamp()
    },
    var.additional_tags
  )
}
