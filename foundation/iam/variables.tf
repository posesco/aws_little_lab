variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "iam_groups" {
  type = map(object({
    path     = string
    policies = list(string)
  }))

  default = {
    developers = {
      path = "/users/"
      policies = [
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
        "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
      ]
    }
    finance = {
      path = "/users/"
      policies = [
        "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
      ]
    }
    admins = {
      path = "/users/"
      policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
    }
    cli-deployers = {
      path = "/service-accounts/"
      policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess",
        "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
      ]
    }
  }
}

variable "iam_users" {
  type = map(object({
    path              = string
    groups            = list(string)
    console_access    = bool
    create_access_key = bool
  }))

  default = {
    john-developer = {
      path              = "/users/"
      groups            = ["developers"]
      console_access    = true
      create_access_key = false
    }
    jane-developer = {
      path              = "/users/"
      groups            = ["developers"]
      console_access    = true
      create_access_key = false
    }
    alice-finance = {
      path              = "/users/"
      groups            = ["finance"]
      console_access    = true
      create_access_key = false
    }
    master = {
      path              = "/users/"
      groups            = ["admins"]
      console_access    = true
      create_access_key = false
    }
    pipeline-dev = {
      path              = "/service-accounts/"
      groups            = ["cli-deployers"]
      console_access    = false
      create_access_key = true
    }

  }
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in format 'owner/repo' (e.g., 'hashicorp/terraform')"
}

variable "github_oidc_allowed_subjects" {
  type        = list(string)
  description = "List of allowed subject patterns for OIDC (e.g., 'ref:refs/heads/master', 'environment:prod', 'pull_request')"
  default = [
    "ref:refs/heads/master",
    "pull_request",
    "environment:dev",
    "environment:staging",
    "environment:prod"
  ]
}

variable "tfstate_bucket_name" {
  type        = string
  description = "Name of the S3 bucket storing Terraform state (for OIDC role permissions)"
}

# TODO: Implement Secrets Manager storage for access keys
variable "store_keys_in_secrets_manager" {
  type        = bool
  description = "Store service account keys in AWS Secrets Manager instead of local CSV (not yet implemented)"
  default     = false
}
