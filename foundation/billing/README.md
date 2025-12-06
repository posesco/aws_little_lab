## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

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
| <a name="input_alert_emails"></a> [alert\_emails](#input\_alert\_emails) | Emails to receive budget alerts | `list(string)` | n/a | yes |
| <a name="input_alert_thresholds"></a> [alert\_thresholds](#input\_alert\_thresholds) | Percentages for alerts (e.g., [80, 90, 100]) | `list(number)` | <pre>[<br/>  80,<br/>  90,<br/>  100<br/>]</pre> | no |
| <a name="input_budget_limit"></a> [budget\_limit](#input\_budget\_limit) | Monthly budget limit in USD | `number` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Deployment environment name | `string` | `"dev"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget_limit"></a> [budget\_limit](#output\_budget\_limit) | Configured budget limit |
| <a name="output_budget_name"></a> [budget\_name](#output\_budget\_name) | Budget name |
