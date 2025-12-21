## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common_tags"></a> [common\_tags](#module\_common\_tags) | ../../modules/common-tags | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_budgets_budget.monthly_cost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_emails"></a> [alert\_emails](#input\_alert\_emails) | Emails to receive budget alerts | `list(string)` | <pre>[<br/>  "example@example.com",<br/>  "example2@example.com"<br/>]</pre> | no |
| <a name="input_alert_thresholds"></a> [alert\_thresholds](#input\_alert\_thresholds) | Percentages for alerts (e.g., [80, 90, 100]) | `list(number)` | <pre>[<br/>  80,<br/>  90,<br/>  100<br/>]</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region (note: Budgets API always uses us-east-1 internally) | `string` | n/a | yes |
| <a name="input_budget_limits"></a> [budget\_limits](#input\_budget\_limits) | Monthly budget limit in USD per environment | `map(number)` | <pre>{<br/>  "dev": 10,<br/>  "prod": 30,<br/>  "staging": 20<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget_limit"></a> [budget\_limit](#output\_budget\_limit) | Configured budget limit |
| <a name="output_budget_name"></a> [budget\_name](#output\_budget\_name) | Budget name |

## Diagram

![Terraform Graph](../../media/billing_graph.svg)
