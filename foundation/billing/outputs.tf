output "budget_name" {
  description = "Budget name"
  value       = aws_budgets_budget.monthly_cost.name
}
output "budget_limit" {
  description = "Configured budget limit"
  value       = "${aws_budgets_budget.monthly_cost.limit_amount} ${aws_budgets_budget.monthly_cost.limit_unit}"
}