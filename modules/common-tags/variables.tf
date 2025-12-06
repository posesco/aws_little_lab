variable "env" {
  type        = string
  description = "Environment (dev, staging, prod)"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to merge with base tags"
  default     = {}
}
