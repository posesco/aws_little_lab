terraform {
  backend "s3" {
    bucket               = "terraform-state-bucket-unique-posesco"
    key                  = "projects/rds_db/terraform.tfstate"
    region               = "eu-west-1"
    encrypt              = true
    use_lockfile         = true
    workspace_key_prefix = "workspaces"
  }
}
