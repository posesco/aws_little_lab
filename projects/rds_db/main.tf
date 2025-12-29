module "common_tags" {
  source  = "../../modules/common-tags"
  env     = local.env
  project = var.project
}

locals {
  env         = terraform.workspace
  common_tags = module.common_tags.tags
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

data "terraform_remote_state" "ec2_n8n" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket               = "terraform-state-bucket-unique-posesco"
    key                  = "projects/n8n/terraform.tfstate"
    region               = "eu-west-1"
    workspace_key_prefix = "workspaces"
  }
}
