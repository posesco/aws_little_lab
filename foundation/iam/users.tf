resource "aws_iam_user" "users" {
  for_each = var.iam_users

  name = each.key
  path = each.value.path

  tags = merge(
    local.common_tags,
    {
      Type    = each.value.console_access ? "Human" : "ServiceAccount"
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

