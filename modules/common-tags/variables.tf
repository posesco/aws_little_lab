variable "env" {
  type        = string
  description = "Environment (dev, staging, prod, global)"
  validation {
    condition     = contains(["dev", "staging", "prod", "global"], var.env)
    error_message = "Environment must be dev, staging, prod, or global."
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
