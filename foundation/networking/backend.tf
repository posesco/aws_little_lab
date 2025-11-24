terraform {
  backend "s3" {
    bucket         = "terraform-state-XXXXXXXXXX"  # Cambiar por el bucket creado
    key            = "foundation/networking/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

terraform {
  backend "s3" {
    bucket               = "terraform-state-bucket-unique-posesco"
    key                  = "foundation/networking/terraform.tfstate"
    region               = "eu-west-1"
    encrypt              = true
    use_lockfile         = true
    workspace_key_prefix = "terraform-workspaces"
  }
}
