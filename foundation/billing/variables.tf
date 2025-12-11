variable "aws_region" {
  type        = string
  description = "AWS Region (note: Budgets API always uses us-east-1 internally)"
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

variable "budget_limit" {
  description = "Monthly budget limit in USD"
  type        = number
  validation {
    condition     = var.budget_limit > 0
    error_message = "budget_limit must be greater than 0"
  }
}

variable "alert_emails" {
  description = "Emails to receive budget alerts"
  type        = list(string)
}

variable "alert_thresholds" {
  description = "Percentages for alerts (e.g., [80, 90, 100])"
  type        = list(number)
  default     = [80, 90, 100]
}