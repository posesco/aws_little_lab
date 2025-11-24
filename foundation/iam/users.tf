# Usuario developer con capacidad de asumir roles
module "developer_user" {
  source = "../../modules/iam-user-with-mfa"

  username           = var.developer_username
  create_access_key  = true
  assumable_role_arns = [
    aws_iam_role.developer.arn
  ]

  tags = merge(
    local.common_tags,
    {
      Name = var.developer_username
      Role = "Developer"
    }
  )
}

