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

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-unique-posesco"
    key    = "foundation/iam/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "aws_ami" "os" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
