module "common_tags" {
  source  = "../../modules/common-tags"
  env     = "global"
  project = "foundation"
  additional_tags = {
    Component = "shared-tfstate"
  }
}

locals {
  common_tags = module.common_tags.tags
}
