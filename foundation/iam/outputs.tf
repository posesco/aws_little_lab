output "user_arns" {
  description = "Map of usernames to ARNs"
  value = {
    for username, user in aws_iam_user.users :
    username => user.arn
  }
}

output "service_account_access_keys" {
  description = "Access keys for service accounts (SENSITIVE)"
  value = {
    for username, key in aws_iam_access_key.user_keys :
    username => {
      access_key_id     = key.id
      secret_access_key = key.secret
    }
  }
  sensitive = true
}

output "console_users" {
  description = "Users with console access (need password setup)"
  value = [
    for username, config in var.iam_users :
    username if config.console_access
  ]
}

output "setup_instructions" {
  description = "Commands to set up user passwords"
  value       = <<-EOT
    
    === SETUP CONSOLE PASSWORDS ===
    Run these commands with AWS CLI:
    
    %{for username, config in var.iam_users~}
    %{if config.console_access~}
    # ${username}
    aws iam create-login-profile \
      --user-name ${username} \
      --password "ThisPass2025NeedChanges" \
      --password-reset-required
    
    %{endif~}
    %{endfor~}
  EOT
}