module "common_tags" {
  source  = "../../modules/common-tags"
  env     = var.env
  project = "foundation"
  additional_tags = {
    Component = "iam"
  }
}

locals {
  common_tags = module.common_tags.tags
}

data "aws_iam_policy" "billing_ro_access" {
  arn = "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
}

data "aws_iam_policy" "rds_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

data "aws_iam_policy" "ec2_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

data "aws_iam_policy" "s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

data "aws_iam_policy" "lambda_full_access" {
  arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}
