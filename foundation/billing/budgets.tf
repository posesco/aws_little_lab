

# SNS Topic para notificaciones de presupuesto
resource "aws_sns_topic" "budget_alerts" {
  provider = aws.us_east_1
  name     = "${var.env}-budget-alerts"

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

  name              = "${var.env}-monthly-budget"
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
    values = ["Env"]
  }
}

# Budget por servicio (EC2)
resource "aws_budgets_budget" "ec2_cost" {
  provider = aws.us_east_1

  name              = "${var.env}-ec2-budget"
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

  name              = "${var.env}-rds-budget"
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

  alarm_name          = "${var.env}-billing-alarm"
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

