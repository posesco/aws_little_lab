output "user_arns" {
  description = "Map of usernames to ARNs"
  value = {
    for username, user in aws_iam_user.users :
    username => user.arn
  }
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

output "assume_cost_explorer_role_commands" {
  description = "Commands to assume Cost Explorer role and query costs"
  value       = <<-EOT
    
    ═══════════════════════════════════════════════════════════
    🔐 ASSUME COST EXPLORER ROLE
    ═══════════════════════════════════════════════════════════
    
    ROLE ARN: ${aws_iam_role.cost_explorer_reader.arn}
    
    ─────────────────────────────────────────────────────────
    OPTION 1: Temporary credentials (manual)
    ─────────────────────────────────────────────────────────
    
    # Assume role and get temporary credentials
    aws sts assume-role \
      --role-arn ${aws_iam_role.cost_explorer_reader.arn} \
      --role-session-name cost-explorer-session \
      --output json > /tmp/assumed-role.json
    
    # Export credentials to environment
    export AWS_ACCESS_KEY_ID=$(jq -r .Credentials.AccessKeyId /tmp/assumed-role.json)
    export AWS_SECRET_ACCESS_KEY=$(jq -r .Credentials.SecretAccessKey /tmp/assumed-role.json)
    export AWS_SESSION_TOKEN=$(jq -r .Credentials.SessionToken /tmp/assumed-role.json)
    
    # Now run Cost Explorer commands
    aws ce get-cost-and-usage \
      --time-period Start=2025-11-01,End=2025-11-30 \
      --granularity MONTHLY \
      --metrics BlendedCost
    
    # Clear credentials when done
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
    
    ─────────────────────────────────────────────────────────
    OPTION 2: One-liner with AWS profile (recommended)
    ─────────────────────────────────────────────────────────
    
    # Add to ~/.aws/config
    cat >> ~/.aws/config << 'EOF'
    
    [profile cost-explorer]
    role_arn = ${aws_iam_role.cost_explorer_reader.arn}
    source_profile = pipeline-prod
    EOF
    
    # Add service account credentials to ~/.aws/credentials
    cat >> ~/.aws/credentials << 'EOF'
    
    [pipeline-prod]
    aws_access_key_id = YOUR_SERVICE_ACCOUNT_ACCESS_KEY
    aws_secret_access_key = YOUR_SERVICE_ACCOUNT_SECRET_KEY
    EOF
    
    # Use the profile
    aws ce get-cost-and-usage \
      --profile cost-explorer \
      --time-period Start=2025-11-01,End=2025-11-30 \
      --granularity MONTHLY \
      --metrics BlendedCost
    
    ─────────────────────────────────────────────────────────
    OPTION 3: Shell function (easiest for daily use)
    ─────────────────────────────────────────────────────────
    
    # Add to ~/.bashrc or ~/.zshrc
    assume-cost-explorer() {
      local creds=$(aws sts assume-role \
        --role-arn ${aws_iam_role.cost_explorer_reader.arn} \
        --role-session-name cost-explorer-\$\$\$(date +%s) \
        --output json)
      
      export AWS_ACCESS_KEY_ID=$(echo $creds | jq -r .Credentials.AccessKeyId)
      export AWS_SECRET_ACCESS_KEY=$(echo $creds | jq -r .Credentials.SecretAccessKey)
      export AWS_SESSION_TOKEN=$(echo $creds | jq -r .Credentials.SessionToken)
      
      echo "✅ Cost Explorer role assumed. Credentials expire in 1 hour."
      echo "Run 'unassume-role' when done."
    }
    
    unassume-role() {
      unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
      echo "✅ Role credentials cleared."
    }
    
    # Usage:
    assume-cost-explorer
    aws ce get-cost-and-usage --time-period Start=2025-11-01,End=2025-11-30 --granularity MONTHLY --metrics BlendedCost
    unassume-role
    
    ═══════════════════════════════════════════════════════════
    
  EOT
}