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
| [aws_instance.lab_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.lab_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow_ssh_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_ami.os](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [terraform_remote_state.networking](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ssh_cidr_ipv4"></a> [allowed\_ssh\_cidr\_ipv4](#input\_allowed\_ssh\_cidr\_ipv4) | CIDR block allowed for SSH access | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment (dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `"t4g.small"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Name of the SSH key pair in AWS | `string` | n/a | yes |
| <a name="input_lab_volume_size"></a> [lab\_volume\_size](#input\_lab\_volume\_size) | Size of the root volume in GB | `number` | `10` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | `"n8n"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | EC2 instance ID |
| <a name="output_instance_public_dns"></a> [instance\_public\_dns](#output\_instance\_public\_dns) | Public DNS assigned to the instance |
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | Public IP assigned to the instance |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID |
