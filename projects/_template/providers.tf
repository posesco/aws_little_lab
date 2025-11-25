terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Obtener outputs del foundation/iam para asumir role
# data "terraform_remote_state" "iam" {
#   backend = "s3"
#   config = {
#     bucket = "terraform-state-XXXXXXXXXX"  # Cambiar por el bucket creado
#     key    = "foundation/iam/terraform.tfstate"
#     region = "eu-west-1"
#   }
# }

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-unique-posesco"
    key    = "foundation/networking/terraform.tfstate"
    region = "eu-west-1"
  }
}

# Provider principal con role assumption
provider "aws" {
  region = var.aws_region

  # Asumir el role developer
  assume_role {
    role_arn     = data.terraform_remote_state.iam.outputs.developer_role_arn
    session_name = "terraform-${var.project_name}"
  }

  default_tags {
    tags = module.common_tags.tags
  }
}

