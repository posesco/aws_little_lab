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
| [aws_iam_user.users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_group_membership.user_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_group_membership) | resource |
| [aws_iam_user_policy_attachment.console_change_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [local_file.console_users_info](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.service_account_keys](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Deployment environment name | `string` | `"dev"` | no |
| <a name="input_iam_groups"></a> [iam\_groups](#input\_iam\_groups) | n/a | <pre>map(object({<br/>    path     = string<br/>    policies = list(string)<br/>  }))</pre> | <pre>{<br/>  "admins": {<br/>    "path": "/users/",<br/>    "policies": [<br/>      "arn:aws:iam::aws:policy/AdministratorAccess"<br/>    ]<br/>  },<br/>  "developers": {<br/>    "path": "/users/",<br/>    "policies": [<br/>      "arn:aws:iam::aws:policy/AmazonEC2FullAccess",<br/>      "arn:aws:iam::aws:policy/AmazonRDSFullAccess"<br/>    ]<br/>  },<br/>  "finance": {<br/>    "path": "/users/",<br/>    "policies": [<br/>      "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"<br/>    ]<br/>  },<br/>  "pipeline-deployers": {<br/>    "path": "/service-accounts/",<br/>    "policies": [<br/>      "arn:aws:iam::aws:policy/PowerUserAccess",<br/>      "arn:aws:iam::aws:policy/IAMReadOnlyAccess"<br/>    ]<br/>  }<br/>}</pre> | no |
| <a name="input_iam_users"></a> [iam\_users](#input\_iam\_users) | n/a | <pre>map(object({<br/>    path              = string<br/>    groups            = list(string)<br/>    console_access    = bool<br/>    create_access_key = bool<br/>  }))</pre> | <pre>{<br/>  "alice-finance": {<br/>    "console_access": true,<br/>    "create_access_key": false,<br/>    "groups": [<br/>      "finance"<br/>    ],<br/>    "path": "/users/"<br/>  },<br/>  "jane-developer": {<br/>    "console_access": true,<br/>    "create_access_key": false,<br/>    "groups": [<br/>      "developers"<br/>    ],<br/>    "path": "/users/"<br/>  },<br/>  "john-developer": {<br/>    "console_access": true,<br/>    "create_access_key": false,<br/>    "groups": [<br/>      "developers"<br/>    ],<br/>    "path": "/users/"<br/>  },<br/>  "master": {<br/>    "console_access": true,<br/>    "create_access_key": false,<br/>    "groups": [<br/>      "admins"<br/>    ],<br/>    "path": "/users/"<br/>  },<br/>  "pipeline-dev": {<br/>    "console_access": false,<br/>    "create_access_key": true,<br/>    "groups": [<br/>      "pipeline-deployers"<br/>    ],<br/>    "path": "/service-accounts/"<br/>  }<br/>}</pre> | no |
| <a name="input_store_keys_in_secrets_manager"></a> [store\_keys\_in\_secrets\_manager](#input\_store\_keys\_in\_secrets\_manager) | Store service account keys in AWS Secrets Manager instead of local CSV | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_csv_files_created"></a> [csv\_files\_created](#output\_csv\_files\_created) | Paths to generated CSV files |
| <a name="output_user_arns"></a> [user\_arns](#output\_user\_arns) | Map of usernames to ARNs |
