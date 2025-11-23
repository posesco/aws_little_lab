# ============================================
# foundation/billing/backend.tf
# ============================================
terraform {
  backend "s3" {
    bucket         = "terraform-state-XXXXXXXXXX"  # Cambiar por el bucket creado
    key            = "foundation/billing/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

# ============================================
# foundation/billing/providers.tf
# ============================================
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Budgets deben crearse en us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.environment
      Component   = "foundation-billing"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.environment
      Component   = "foundation-billing"
    }
  }
}

# ============================================
# foundation/billing/variables.tf
# ============================================
variable "aws_region" {
  description = "Región principal de AWS"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "budget_limit_euros" {
  description = "Límite mensual de presupuesto en EUR"
  type        = number
  default     = 15
}

variable "alert_emails" {
  description = "Emails para recibir alertas de presupuesto"
  type        = list(string)
}

variable "alert_thresholds" {
  description = "Porcentajes para alertas (ej: [80, 90, 100])"
  type        = list(number)
  default     = [80, 90, 100]
}

variable "lab_owner" {
  description = "Propietario del laboratorio"
  type        = string
}

# ============================================
# foundation/billing/budgets.tf
# ============================================
locals {
  common_tags = {
    ManagedBy   = "Terraform"
    Environment = var.environment
    Owner       = var.lab_owner
    Component   = "billing-alerts"
  }
}

# SNS Topic para notificaciones de presupuesto
resource "aws_sns_topic" "budget_alerts" {
  provider = aws.us_east_1
  name     = "${var.environment}-budget-alerts"

  tags = local.common_tags
}

# Subscripciones de email al SNS Topic
resource "aws_sns_topic_subscription" "budget_email_alerts" {
  provider  = aws.us_east_1
  count     = length(var.alert_emails)
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_emails[count.index]
}

# Budget principal
resource "aws_budgets_budget" "monthly_cost" {
  provider = aws.us_east_1

  name              = "${var.environment}-monthly-budget"
  budget_type       = "COST"
  limit_amount      = tostring(var.budget_limit_euros)
  limit_unit        = "USD" # AWS Budgets usa USD, luego convierte
  time_unit         = "MONTHLY"
  time_period_start = "2024-01-01_00:00"

  # Alertas a diferentes umbrales
  dynamic "notification" {
    for_each = var.alert_thresholds

    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = var.alert_emails
    }
  }

  # Alerta de pronóstico (si se proyecta superar el límite)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_email_addresses = var.alert_emails
  }

  cost_filter {
    name   = "TagKey"
    values = ["Environment"]
  }
}

# Budget por servicio (EC2)
resource "aws_budgets_budget" "ec2_cost" {
  provider = aws.us_east_1

  name              = "${var.environment}-ec2-budget"
  budget_type       = "COST"
  limit_amount      = tostring(var.budget_limit_euros * 0.4) # 40% del total
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2024-01-01_00:00"

  cost_filter {
    name   = "Service"
    values = ["Amazon Elastic Compute Cloud - Compute"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
  }
}

# Budget por servicio (RDS)
resource "aws_budgets_budget" "rds_cost" {
  provider = aws.us_east_1

  name              = "${var.environment}-rds-budget"
  budget_type       = "COST"
  limit_amount      = tostring(var.budget_limit_euros * 0.3) # 30% del total
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2024-01-01_00:00"

  cost_filter {
    name   = "Service"
    values = ["Amazon Relational Database Service"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
  }
}

# CloudWatch Alarm para monitorear costos estimados
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  provider = aws.us_east_1

  alarm_name          = "${var.environment}-billing-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "21600" # 6 horas
  statistic           = "Maximum"
  threshold           = var.budget_limit_euros
  alarm_description   = "Alerta cuando el gasto estimado supera ${var.budget_limit_euros} EUR"
  alarm_actions       = [aws_sns_topic.budget_alerts.arn]

  dimensions = {
    Currency = "USD"
  }

  tags = local.common_tags
}

# ============================================
# foundation/billing/outputs.tf
# ============================================
output "budget_name" {
  description = "Nombre del presupuesto mensual"
  value       = aws_budgets_budget.monthly_cost.name
}

output "budget_limit" {
  description = "Límite de presupuesto configurado"
  value       = "${aws_budgets_budget.monthly_cost.limit_amount} ${aws_budgets_budget.monthly_cost.limit_unit}"
}

output "sns_topic_arn" {
  description = "ARN del SNS topic para alertas"
  value       = aws_sns_topic.budget_alerts.arn
}

output "alert_emails" {
  description = "Emails configurados para alertas"
  value       = var.alert_emails
  sensitive   = true
}

output "cloudwatch_alarm_name" {
  description = "Nombre de la alarma de CloudWatch"
  value       = aws_cloudwatch_metric_alarm.billing_alarm.alarm_name
}

# ============================================
# foundation/billing/terraform.tfvars.example
# ============================================
# Copia este archivo a terraform.tfvars y completa los valores

aws_region  = "eu-west-1"
environment = "dev"

# Propietario del laboratorio
lab_owner = "tu-nombre@example.com"

# Límite de presupuesto mensual en EUROS
budget_limit_euros = 15

# Emails para recibir alertas (confirmar suscripción en inbox)
alert_emails = [
  "tu-email@example.com"
]

# Umbrales de alerta (en porcentaje)
# 80% = 12 EUR, 90% = 13.5 EUR, 100% = 15 EUR
alert_thresholds = [80, 90, 100]