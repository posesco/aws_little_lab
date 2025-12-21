variable "aws_region" {
  type        = string
  description = "AWS Region (note: Budgets API always uses us-east-1 internally)"
}

variable "budget_limits" {
  description = "Monthly budget limit in USD per environment"
  type        = map(number)
  default = {
    dev     = 10.0
    staging = 20.0
    prod    = 30.0
  }
  validation {
    condition     = alltrue([for v in values(var.budget_limits) : v > 0])
    error_message = "All budget_limits must be greater than 0"
  }
}

variable "alert_emails" {
  description = "Emails to receive budget alerts"
  type        = list(string)
  default     = ["example@example.com", "example2@example.com"]
}

variable "alert_thresholds" {
  description = "Percentages for alerts (e.g., [80, 90, 100])"
  type        = list(number)
  default     = [80, 90, 100]
}