data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  env         = terraform.workspace
  common_tags = module.common_tags.tags
}

module "common_tags" {
  source  = "../../modules/common-tags"
  env     = local.env
  project = "foundation"
  additional_tags = {
    Component = "shared-networking"
  }
}

