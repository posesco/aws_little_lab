data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  common_tags = {
    ManagedBy   = "Terraform"
    Env = var.env
    Owner       = var.owner
    CostCenter  = var.cost_center
  }
}

locals {
  common_tags = {
    ManagedBy = "Terraform"
    Env       = var.env
    Owner     = var.owner
    Component = "iam"
  }
}

# ============================================
# GRUPOS IAM
# ============================================

resource "aws_iam_group" "developers" {
  name = "${var.project}-developers"
  path = "/users/"
}

resource "aws_iam_group" "finance" {
  name = "${var.project}-finance"
  path = "/users/"
}

resource "aws_iam_group" "admins" {
  name = "${var.project}-admins"
  path = "/users/"
}

resource "aws_iam_group" "pipeline_deployers" {
  name = "${var.project}-pipeline-deployers"
  path = "/service-accounts/"
}

# ============================================
# POLÍTICAS AWS MANAGED
# ============================================

# Developers - Permisos amplios para desarrollo
resource "aws_iam_group_policy_attachment" "developers_ec2_full" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "developers_rds_full" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_group_policy_attachment" "developers_s3_full" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "developers_lambda_full" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

# Finance - Solo lectura billing
resource "aws_iam_group_policy_attachment" "finance_billing" {
  group      = aws_iam_group.finance.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

# Admins - Acceso casi completo
resource "aws_iam_group_policy_attachment" "admins_administrator" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Pipeline Deployers - PowerUser (todo menos IAM)
resource "aws_iam_group_policy_attachment" "pipeline_poweruser" {
  group      = aws_iam_group.pipeline_deployers.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# Pipeline necesita leer IAM para pasar roles
resource "aws_iam_group_policy_attachment" "pipeline_iam_read" {
  group      = aws_iam_group.pipeline_deployers.name
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

# ============================================
# POLÍTICA INLINE PARA PASS ROLE (Pipeline)
# ============================================

resource "aws_iam_group_policy" "pipeline_pass_role" {
  name  = "allow-pass-role"
  group = aws_iam_group.pipeline_deployers.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPassRoleToServices"
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "iam:GetRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = [
              "ec2.amazonaws.com",
              "lambda.amazonaws.com",
              "rds.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# ============================================
# POLÍTICA DE PASSWORD (Opcional)
# ============================================

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 5
}