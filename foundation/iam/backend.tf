terraform {
  backend "s3" {
    bucket         = "terraform-state-XXXXXXXXXX"  # Cambiar por el bucket creado
    key            = "foundation/iam/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
