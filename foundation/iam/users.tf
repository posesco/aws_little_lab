resource "aws_iam_user" "users" {
  for_each = var.iam_users

  name = each.key
  path = each.value.path

  tags = merge(
    local.common_tags,
    {
      Type    = each.value.console_access ? "human" : "serviceAccount"
      Console = each.value.console_access ? "enabled" : "disabled"
    }
  )
}

resource "aws_iam_user_policy_attachment" "console_change_password" {
  for_each = {
    for username, config in var.iam_users :
    username => config if config.console_access
  }

  user       = aws_iam_user.users[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

resource "aws_iam_user_group_membership" "user_groups" {
  for_each = var.iam_users

  user   = aws_iam_user.users[each.key].name
  groups = each.value.groups
}

resource "aws_iam_access_key" "user_keys" {
  for_each = {
    for username, config in var.iam_users :
    username => config if config.create_access_key
  }

  user = aws_iam_user.users[each.key].name
}

resource "local_file" "service_account_keys" {
  content         = local.service_accounts_csv
  filename        = "${path.module}/service-account-keys.csv"
  file_permission = "0600"

  depends_on = [aws_iam_access_key.user_keys]
}

resource "local_file" "console_users_info" {
  content         = local.console_users_csv
  filename        = "${path.module}/console-users.csv"
  file_permission = "0644"

  depends_on = [aws_iam_user.users]
}
