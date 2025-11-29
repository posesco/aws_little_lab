variable "aws_region" {
  type        = string
  description = "AWS Region"
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
variable "state_bucket_name" {
  type        = string
  description = "Bucket name, must be unique"
}
