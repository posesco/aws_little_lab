variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "rds_db"
}