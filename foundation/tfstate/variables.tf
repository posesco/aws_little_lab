variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = ""
}

variable "project" {
  type        = string
  description = "Project name"
  default     = ""
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
  default     = ""
}

variable "state_bucket_name" {
  type        = string
  description = "Bucket name, must be unique"
}
