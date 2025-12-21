module "common_tags" {
  source  = "../../modules/common-tags"
  env     = "global"
  project = "foundation"
  additional_tags = {
    Component = "iam"
  }
}

data "aws_iam_policy_document" "cost_explorer_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        for username in keys(local.service_accounts) :
        aws_iam_user.users[username].arn
      ]
    }

    actions = ["sts:AssumeRole"]

  }
}
locals {
  common_tags = module.common_tags.tags
  service_accounts = {
    for username, config in var.iam_users :
    username => config if config.create_access_key
  }
  console_users = {
    for username, config in var.iam_users :
    username => config if config.console_access
  }
  service_accounts_csv = join("\n", concat(
    ["username,access_key_id,secret_access_key,created_at"],
    [
      for username in keys(local.service_accounts) :
      "${username},${aws_iam_access_key.user_keys[username].id},${aws_iam_access_key.user_keys[username].secret},${timestamp()}"
    ]
  ))
  console_users_csv = join("\n", concat(
    ["username,path,groups,console_url,password_status"],
    [
      for username in keys(local.console_users) :
      "${username},${local.console_users[username].path},${join("|", local.console_users[username].groups)},https://console.aws.amazon.com/,PENDING_SETUP"
    ]
  ))
}