variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "rds-db"
}

variable "db_name" {
  type        = string
  description = "Name of the initial database"
  default     = "shared_db"
  validation {
    condition     = can(regex("^[a-z][a-z0-9_]*$", var.db_name))
    error_message = "Database name must start with a letter and contain only lowercase letters, numbers, and underscores."
  }
}

variable "db_username" {
  type        = string
  description = "Master username for the database"
  default     = "dbadmin"
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_username))
    error_message = "Username must start with a letter and contain only alphanumeric characters and underscores."
  }
}

variable "db_instance_class" {
  type        = map(string)
  description = "RDS instance class per environment"
  default = {
    dev     = "db.t4g.micro"
    staging = "db.t4g.small"
    prod    = "db.t4g.medium"
  }
  validation {
    condition = alltrue([
      for value in values(var.db_instance_class) :
      can(regex("^db\\.[a-z0-9]+\\.(micro|small|medium|large|xlarge|[0-9]+xlarge)$", value))
    ])
    error_message = "Invalid RDS instance class format."
  }
}

variable "db_allocated_storage" {
  type        = map(number)
  description = "Allocated storage in GB per environment"
  default = {
    dev     = 20
    staging = 50
    prod    = 100
  }
  validation {
    condition     = alltrue([for value in values(var.db_allocated_storage) : value >= 20 && value <= 65536])
    error_message = "Allocated storage must be between 20 and 65536 GB."
  }
}

variable "db_max_allocated_storage" {
  type        = map(number)
  description = "Maximum allocated storage for autoscaling in GB per environment"
  default = {
    dev     = 50
    staging = 100
    prod    = 200
  }
  validation {
    condition     = alltrue([for value in values(var.db_max_allocated_storage) : value >= 20 && value <= 65536])
    error_message = "Max allocated storage must be between 20 and 65536 GB."
  }
}

variable "db_engine_version" {
  type        = string
  description = "PostgreSQL engine version"
  default     = "16"
  validation {
    condition     = can(regex("^[0-9]+$", var.db_engine_version))
    error_message = "Engine version must be a major version number (e.g., 14, 15, 16)."
  }
}

variable "db_multi_az" {
  type        = map(bool)
  description = "Enable Multi-AZ deployment per environment"
  default = {
    dev     = false
    staging = false
    prod    = true
  }
}

variable "db_backup_retention_period" {
  type        = map(number)
  description = "Backup retention period in days per environment"
  default = {
    dev     = 1
    staging = 7
    prod    = 7
  }
  validation {
    condition     = alltrue([for value in values(var.db_backup_retention_period) : value >= 0 && value <= 35])
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "db_deletion_protection" {
  type        = map(bool)
  description = "Enable deletion protection per environment"
  default = {
    dev     = false
    staging = false
    prod    = true
  }
}

variable "db_skip_final_snapshot" {
  type        = map(bool)
  description = "Skip final snapshot when deleting per environment"
  default = {
    dev     = true
    staging = true
    prod    = false
  }
}

variable "db_performance_insights_enabled" {
  type        = map(bool)
  description = "Enable Performance Insights per environment"
  default = {
    dev     = false
    staging = false
    prod    = true
  }
}

variable "db_cloudwatch_logs_exports" {
  type        = map(list(string))
  description = "List of log types to export to CloudWatch per environment"
  default = {
    dev     = []
    staging = ["postgresql"]
    prod    = ["postgresql", "upgrade"]
  }
}
