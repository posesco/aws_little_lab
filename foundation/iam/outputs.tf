output "user_arns" {
  description = "Map of usernames to ARNs"
  value = {
    for username, user in aws_iam_user.users :
    username => user.arn
  }
}

output "service_account_access_keys" {
  description = "Access key IDs for service accounts"
  value = {
    for username, key in aws_iam_access_key.user_keys :
    username => key.id
  }
}

output "service_account_secret_keys" {
  description = "Secret access keys for service accounts"
  value = {
    for username, key in aws_iam_access_key.user_keys :
    username => key.secret
  }
  sensitive = true
}

output "csv_files_created" {
  description = "Paths to generated CSV files"
  value = {
    service_accounts = abspath(local_file.service_account_keys.filename)
    console_users    = abspath(local_file.console_users_info.filename)
  }
}

output "cost_explorer_role_arn" {
  description = "ARN of Cost Explorer Reader role"
  value       = aws_iam_role.cost_explorer_reader.arn
}