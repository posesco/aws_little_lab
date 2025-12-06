data "aws_availability_zones" "available" {
  state = "available"
}

module "common_tags" {
  source  = "../../modules/common-tags"
  env     = var.env
  project = "foundation"
  additional_tags = {
    Component = "shared-networking"
  }
}

locals {
  common_tags = module.common_tags.tags
}
