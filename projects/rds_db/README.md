## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common_tags"></a> [common\_tags](#module\_common\_tags) | ../../modules/common-tags | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_parameter_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_security_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_ingress_rule.allow_postgres_from_n8n](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [terraform_remote_state.ec2_n8n](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.networking](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | Allocated storage in GB per environment | `map(number)` | <pre>{<br/>  "dev": 20,<br/>  "prod": 100,<br/>  "staging": 50<br/>}</pre> | no |
| <a name="input_db_backup_retention_period"></a> [db\_backup\_retention\_period](#input\_db\_backup\_retention\_period) | Backup retention period in days per environment | `map(number)` | <pre>{<br/>  "dev": 1,<br/>  "prod": 7,<br/>  "staging": 7<br/>}</pre> | no |
| <a name="input_db_cloudwatch_logs_exports"></a> [db\_cloudwatch\_logs\_exports](#input\_db\_cloudwatch\_logs\_exports) | List of log types to export to CloudWatch per environment | `map(list(string))` | <pre>{<br/>  "dev": [],<br/>  "prod": [<br/>    "postgresql",<br/>    "upgrade"<br/>  ],<br/>  "staging": [<br/>    "postgresql"<br/>  ]<br/>}</pre> | no |
| <a name="input_db_deletion_protection"></a> [db\_deletion\_protection](#input\_db\_deletion\_protection) | Enable deletion protection per environment | `map(bool)` | <pre>{<br/>  "dev": false,<br/>  "prod": true,<br/>  "staging": false<br/>}</pre> | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | PostgreSQL engine version | `string` | `"16"` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | RDS instance class per environment | `map(string)` | <pre>{<br/>  "dev": "db.t4g.micro",<br/>  "prod": "db.t4g.medium",<br/>  "staging": "db.t4g.small"<br/>}</pre> | no |
| <a name="input_db_max_allocated_storage"></a> [db\_max\_allocated\_storage](#input\_db\_max\_allocated\_storage) | Maximum allocated storage for autoscaling in GB per environment | `map(number)` | <pre>{<br/>  "dev": 50,<br/>  "prod": 200,<br/>  "staging": 100<br/>}</pre> | no |
| <a name="input_db_multi_az"></a> [db\_multi\_az](#input\_db\_multi\_az) | Enable Multi-AZ deployment per environment | `map(bool)` | <pre>{<br/>  "dev": false,<br/>  "prod": true,<br/>  "staging": false<br/>}</pre> | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name of the initial database | `string` | `"shared_db"` | no |
| <a name="input_db_performance_insights_enabled"></a> [db\_performance\_insights\_enabled](#input\_db\_performance\_insights\_enabled) | Enable Performance Insights per environment | `map(bool)` | <pre>{<br/>  "dev": false,<br/>  "prod": true,<br/>  "staging": false<br/>}</pre> | no |
| <a name="input_db_skip_final_snapshot"></a> [db\_skip\_final\_snapshot](#input\_db\_skip\_final\_snapshot) | Skip final snapshot when deleting per environment | `map(bool)` | <pre>{<br/>  "dev": true,<br/>  "prod": false,<br/>  "staging": true<br/>}</pre> | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Master username for the database | `string` | `"dbadmin"` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | `"rds-db"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_connection_string"></a> [db\_connection\_string](#output\_db\_connection\_string) | PostgreSQL connection string template (password from Secrets Manager) |
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | RDS instance endpoint (hostname:port) |
| <a name="output_db_host"></a> [db\_host](#output\_db\_host) | RDS instance hostname |
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | RDS instance ARN |
| <a name="output_db_instance_id"></a> [db\_instance\_id](#output\_db\_instance\_id) | RDS instance ID |
| <a name="output_db_master_secret_arn"></a> [db\_master\_secret\_arn](#output\_db\_master\_secret\_arn) | ARN of the Secrets Manager secret containing the master password |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | Name of the database |
| <a name="output_db_port"></a> [db\_port](#output\_db\_port) | RDS instance port |
| <a name="output_db_security_group_id"></a> [db\_security\_group\_id](#output\_db\_security\_group\_id) | Security group ID for RDS |
| <a name="output_db_subnet_group_name"></a> [db\_subnet\_group\_name](#output\_db\_subnet\_group\_name) | Name of the DB subnet group |
| <a name="output_db_username"></a> [db\_username](#output\_db\_username) | Master username |

## Diagram

![Terraform Graph](../../media/rds_db_graph.svg)
