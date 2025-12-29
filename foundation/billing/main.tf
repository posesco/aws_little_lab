locals {
  env          = terraform.workspace
  budget_limit = lookup(var.budget_limits, local.env, var.budget_limits["dev"])
  common_tags = module.common_tags.tags
}

module "common_tags" {
  source  = "../../modules/common-tags"
  env     = local.env
  project = "foundation"
  additional_tags = {
    Component = "billing-alerts"
  }
}
