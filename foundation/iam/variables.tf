variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "eu-west-1"
}
variable "env" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "Environment must be dev, staging, or prod."
  }
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
        "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
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
    pipeline-deployers = {
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
      groups            = ["pipeline-deployers"]
      console_access    = false
      create_access_key = true
    }

  }
}