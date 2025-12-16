module "common_tags" {
  source  = "../../modules/common-tags"
  env     = var.env
  project = var.project
}

locals {
  common_tags = module.common_tags.tags
}
