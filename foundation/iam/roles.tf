# Role Developer con permisos limitados
resource "aws_iam_role" "developer" {
  name               = "developer-role"
  assume_role_policy = data.aws_iam_policy_document.developer_assume_role.json
  max_session_duration = 43200 # 12 horas

  tags = merge(
    local.common_tags,
    {
      Name = "developer-role"
    }
  )
}

# Trust policy: permite asumir role con MFA
data "aws_iam_policy_document" "developer_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [module.developer_user.user_arn]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "aws:MultiFactorAuthAge"
      values   = ["43200"] # 12 horas
    }
  }
}

# Política inline: EC2
resource "aws_iam_role_policy" "developer_ec2" {
  name = "developer-ec2-policy"
  role = aws_iam_role.developer.id

  policy = templatefile("${path.module}/policies/ec2-policy.json", {
    allowed_regions = jsonencode(var.allowed_regions)
  })
}

# Política inline: Lambda
resource "aws_iam_role_policy" "developer_lambda" {
  name = "developer-lambda-policy"
  role = aws_iam_role.developer.id

  policy = templatefile("${path.module}/policies/lambda-policy.json", {
    allowed_regions = jsonencode(var.allowed_regions)
  })
}

# Política inline: S3
resource "aws_iam_role_policy" "developer_s3" {
  name = "developer-s3-policy"
  role = aws_iam_role.developer.id

  policy = file("${path.module}/policies/s3-policy.json")
}

# Política inline: VPC
resource "aws_iam_role_policy" "developer_vpc" {
  name = "developer-vpc-policy"
  role = aws_iam_role.developer.id

  policy = templatefile("${path.module}/policies/vpc-policy.json", {
    allowed_regions = jsonencode(var.allowed_regions)
  })
}

# Política inline: RDS/Aurora
resource "aws_iam_role_policy" "developer_rds" {
  name = "developer-rds-policy"
  role = aws_iam_role.developer.id

  policy = templatefile("${path.module}/policies/rds-aurora-policy.json", {
    allowed_regions = jsonencode(var.allowed_regions)
  })
}

# Política para requerir tags obligatorios
resource "aws_iam_role_policy" "developer_tag_enforcement" {
  name = "developer-tag-enforcement"
  role = aws_iam_role.developer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RequireTags"
        Effect = "Deny"
        Action = [
          "ec2:RunInstances",
          "rds:CreateDBInstance",
          "s3:CreateBucket",
          "lambda:CreateFunction"
        ]
        Resource = "*"
        Condition = {
          "Null" = {
            "aws:RequestTag/Project"     = "true"
            "aws:RequestTag/Environment" = "true"
            "aws:RequestTag/Owner"       = "true"
          }
        }
      }
    ]
  })
}

