variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "my_project"
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

variable "owner" {
  type        = string
  description = "Project owner"
  default     = "my_owner"
}

variable "state_bucket_name" {
  type        = string
  description = "Bucket name, must be unique"
}
