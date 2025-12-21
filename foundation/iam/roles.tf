resource "aws_iam_role" "cost_explorer_reader" {
  name               = "cost-explorer-reader"
  description        = "Read-only access to Cost Explorer"
  assume_role_policy = data.aws_iam_policy_document.cost_explorer_assume_role.json

  tags = merge(
    local.common_tags,
    {
      ResourceName = "cost-explorer-reader"
      AssumedBy    = "ServiceAccounts"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cost_explorer_access" {
  role       = aws_iam_role.cost_explorer_reader.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
}

resource "aws_iam_role" "ec2_projects" {
  name        = "ec2-projects-role"
  description = "Role for EC2 instances in projects with S3 and DynamoDB access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = merge(
    local.common_tags,
    {
      ResourceName = "ec2-projects-role"
      AssumedBy    = "EC2"
    }
  )
}

resource "aws_iam_instance_profile" "ec2_projects" {
  name = "ec2-projects-profile"
  role = aws_iam_role.ec2_projects.name

  tags = merge(
    local.common_tags,
    {
      ResourceName = "ec2-projects-profile"
    }
  )
}

resource "aws_iam_role" "github_actions" {
  name        = "github-actions-terraform"
  description = "Role assumed by GitHub Actions for Terraform deployments via OIDC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            for pattern in var.github_oidc_allowed_subjects :
            "repo:${var.github_repository}:${pattern}"
          ]
        }
      }
    }]
  })

  tags = merge(
    local.common_tags,
    {
      ResourceName = "github-actions-terraform"
      AssumedBy    = "GitHubActions"
      Repository   = var.github_repository
    }
  )
}

resource "aws_iam_role_policy_attachment" "github_actions_power_user" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy_attachment" "github_actions_iam_readonly" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

