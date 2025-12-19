## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.6.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common_tags"></a> [common\_tags](#module\_common\_tags) | ../../modules/common-tags | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.user_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_group.team_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy_attachment.group_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_instance_profile.ec2_projects](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.cost_explorer_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ec2_projects](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ec2_dynamodb_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ec2_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.github_actions_iam_limited](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.github_actions_tfstate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.cost_explorer_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.github_actions_iam_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.github_actions_power_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user.users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_group_membership.user_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_group_membership) | resource |
| [aws_iam_user_policy_attachment.console_change_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [local_file.console_users_info](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.service_account_keys](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_iam_policy_document.cost_explorer_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Deployment environment name | `string` | `"dev"` | no |
| <a name="input_github_oidc_allowed_subjects"></a> [github\_oidc\_allowed\_subjects](#input\_github\_oidc\_allowed\_subjects) | List of allowed subject patterns for OIDC (e.g., 'ref:refs/heads/main', 'environment:prod', 'pull\_request') | `list(string)` | <pre>[<br/>  "ref:refs/heads/main",<br/>  "pull_request",<br/>  "environment:prod"<br/>]</pre> | no |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | GitHub repository in format 'owner/repo' (e.g., 'hashicorp/terraform') | `string` | n/a | yes |
| <a name="input_iam_groups"></a> [iam\_groups](#input\_iam\_groups) | n/a | <pre>map(object({<br/>    path     = string<br/>    policies = list(string)<br/>  }))</pre> | <pre>{<br/>  "admins": {<br/>    "path": "/users/",<br/>    "policies": [<br/>      "arn:aws:iam::aws:policy/AdministratorAccess"<br/>    ]<br/>  },<br/>  "developers": {<br/>    "path": "/users/",<br/>    "policies": [<br/>      "arn:aws:iam::aws:policy/AmazonEC2FullAccess",<br/>      "arn:aws:iam::aws:policy/AmazonRDSFullAccess"<br/>    ]<br/>  },<br/>  "finance": {<br/>    "path": "/users/",<br/>    "policies": [<br/>      "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"<br/>    ]<br/>  },<br/>  "pipeline-deployers": {<br/>    "path": "/service-accounts/",<br/>    "policies": [<br/>      "arn:aws:iam::aws:policy/PowerUserAccess",<br/>      "arn:aws:iam::aws:policy/IAMReadOnlyAccess"<br/>    ]<br/>  }<br/>}</pre> | no |
| <a name="input_iam_users"></a> [iam\_users](#input\_iam\_users) | n/a | <pre>map(object({<br/>    path              = string<br/>    groups            = list(string)<br/>    console_access    = bool<br/>    create_access_key = bool<br/>  }))</pre> | <pre>{<br/>  "alice-finance": {<br/>    "console_access": true,<br/>    "create_access_key": false,<br/>    "groups": [<br/>      "finance"<br/>    ],<br/>    "path": "/users/"<br/>  },<br/>  "jane-developer": {<br/>    "console_access": true,<br/>    "create_access_key": false,<br/>    "groups": [<br/>      "developers"<br/>    ],<br/>    "path": "/users/"<br/>  },<br/>  "john-developer": {<br/>    "console_access": true,<br/>    "create_access_key": false,<br/>    "groups": [<br/>      "developers"<br/>    ],<br/>    "path": "/users/"<br/>  },<br/>  "master": {<br/>    "console_access": true,<br/>    "create_access_key": false,<br/>    "groups": [<br/>      "admins"<br/>    ],<br/>    "path": "/users/"<br/>  },<br/>  "pipeline-dev": {<br/>    "console_access": false,<br/>    "create_access_key": true,<br/>    "groups": [<br/>      "pipeline-deployers"<br/>    ],<br/>    "path": "/service-accounts/"<br/>  }<br/>}</pre> | no |
| <a name="input_store_keys_in_secrets_manager"></a> [store\_keys\_in\_secrets\_manager](#input\_store\_keys\_in\_secrets\_manager) | Store service account keys in AWS Secrets Manager instead of local CSV (not yet implemented) | `bool` | `false` | no |
| <a name="input_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#input\_tfstate\_bucket\_name) | Name of the S3 bucket storing Terraform state (for OIDC role permissions) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cost_explorer_role_arn"></a> [cost\_explorer\_role\_arn](#output\_cost\_explorer\_role\_arn) | ARN of Cost Explorer Reader role |
| <a name="output_csv_files_created"></a> [csv\_files\_created](#output\_csv\_files\_created) | Paths to generated CSV files |
| <a name="output_ec2_projects_instance_profile_arn"></a> [ec2\_projects\_instance\_profile\_arn](#output\_ec2\_projects\_instance\_profile\_arn) | ARN of EC2 projects instance profile |
| <a name="output_ec2_projects_instance_profile_name"></a> [ec2\_projects\_instance\_profile\_name](#output\_ec2\_projects\_instance\_profile\_name) | Name of EC2 projects instance profile |
| <a name="output_ec2_projects_role_arn"></a> [ec2\_projects\_role\_arn](#output\_ec2\_projects\_role\_arn) | ARN of EC2 projects role |
| <a name="output_github_actions_role_arn"></a> [github\_actions\_role\_arn](#output\_github\_actions\_role\_arn) | ARN of IAM role for GitHub Actions (use this in your workflow) |
| <a name="output_github_actions_role_name"></a> [github\_actions\_role\_name](#output\_github\_actions\_role\_name) | Name of IAM role for GitHub Actions |
| <a name="output_github_oidc_provider_arn"></a> [github\_oidc\_provider\_arn](#output\_github\_oidc\_provider\_arn) | ARN of GitHub OIDC identity provider |
| <a name="output_service_account_access_keys"></a> [service\_account\_access\_keys](#output\_service\_account\_access\_keys) | Access key IDs for service accounts |
| <a name="output_service_account_secret_keys"></a> [service\_account\_secret\_keys](#output\_service\_account\_secret\_keys) | Secret access keys for service accounts |
| <a name="output_user_arns"></a> [user\_arns](#output\_user\_arns) | Map of usernames to ARNs |
