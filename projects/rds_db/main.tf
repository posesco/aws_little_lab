module "common_tags" {
  source  = "../../modules/common-tags"
  env     = local.env
  project = var.project
}

data "terraform_remote_state" "networking" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket               = "terraform-state-bucket-unique-posesco"
    key                  = "foundation/networking/terraform.tfstate"
    region               = "eu-west-1"
    workspace_key_prefix = "workspaces"
  }
}

locals {
  env         = terraform.workspace
  common_tags = module.common_tags.tags
}
