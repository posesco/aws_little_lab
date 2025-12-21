resource "aws_budgets_budget" "monthly_cost" {
  name              = "${local.env}-monthly-budget"
  budget_type       = "COST"
  limit_amount      = tostring(local.budget_limit)
  limit_unit        = "USD"
  time_period_start = "2024-01-01_00:00"
  time_period_end   = "2030-12-31_23:59"
  time_unit         = "MONTHLY"

  dynamic "notification" {
    for_each = var.alert_thresholds

    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = var.alert_emails
    }
  }
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.alert_emails
  }

  tags = merge(
    local.common_tags,
    {
      ResourceName = "${local.env}-monthly-budget"
    }
  )

}
