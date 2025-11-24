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

