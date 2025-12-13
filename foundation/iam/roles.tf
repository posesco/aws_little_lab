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
  name        = "${var.env}-ec2-projects-role"
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
      ResourceName = "${var.env}-ec2-projects-role"
      AssumedBy    = "EC2"
    }
  )
}

resource "aws_iam_role_policy" "ec2_s3_access" {
  name = "${var.env}-ec2-s3-access"
  role = aws_iam_role.ec2_projects.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.env}-*",
          "arn:aws:s3:::${var.env}-*/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_dynamodb_access" {
  name = "${var.env}-ec2-dynamodb-access"
  role = aws_iam_role.ec2_projects.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = "arn:aws:dynamodb:${var.aws_region}:*:table/${var.env}-*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_projects" {
  name = "${var.env}-ec2-projects-profile"
  role = aws_iam_role.ec2_projects.name

  tags = merge(
    local.common_tags,
    {
      ResourceName = "${var.env}-ec2-projects-profile"
    }
  )
}
