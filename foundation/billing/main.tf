module "common_tags" {
  source  = "../../modules/common-tags"
  env     = var.env
  project = "foundation"
  additional_tags = {
    Component = "billing-alerts"
  }
}
locals {
  common_tags = module.common_tags.tags
}
