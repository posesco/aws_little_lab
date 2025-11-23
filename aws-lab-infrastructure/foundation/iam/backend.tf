# ============================================
# foundation/iam/backend.tf
# ============================================
terraform {
  backend "s3" {
    bucket         = "terraform-state-XXXXXXXXXX"  # Cambiar por el bucket creado
    key            = "foundation/iam/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

# ============================================
# foundation/iam/providers.tf
# ============================================
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.environment
      Component   = "foundation-iam"
    }
  }
}

# ============================================
# foundation/iam/variables.tf
# ============================================
variable "aws_region" {
  description = "Región principal de AWS"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "lab_owner" {
  description = "Propietario del laboratorio"
  type        = string
}

variable "allowed_regions" {
  description = "Regiones permitidas para operaciones"
  type        = list(string)
  default     = ["eu-west-1", "eu-central-1"]
}

variable "developer_username" {
  description = "Nombre del usuario developer"
  type        = string
  default     = "lab-developer"
}

variable "cost_center" {
  description = "Centro de costos"
  type        = string
  default     = "personal-lab"
}

variable "allowed_services" {
  description = "Servicios AWS permitidos"
  type        = list(string)
  default = [
    "ec2",
    "lambda",
    "s3",
    "vpc",
    "rds",
    "cloudformation",
    "cloudwatch",
    "logs",
    "iam" # Solo para passthroughs necesarios
  ]
}

# ============================================
# foundation/iam/main.tf
# ============================================
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  common_tags = {
    ManagedBy   = "Terraform"
    Environment = var.environment
    Owner       = var.lab_owner
    CostCenter  = var.cost_center
  }
}

# ============================================
# foundation/iam/users.tf
# ============================================

# Usuario developer con capacidad de asumir roles
module "developer_user" {
  source = "../../modules/iam-user-with-mfa"

  username           = var.developer_username
  create_access_key  = true
  assumable_role_arns = [
    aws_iam_role.developer.arn
  ]

  tags = merge(
    local.common_tags,
    {
      Name = var.developer_username
      Role = "Developer"
    }
  )
}

# ============================================
# foundation/iam/roles.tf
# ============================================

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

# ============================================
# foundation/iam/outputs.tf
# ============================================
output "developer_user_arn" {
  description = "ARN del usuario developer"
  value       = module.developer_user.user_arn
}

output "developer_user_name" {
  description = "Nombre del usuario developer"
  value       = module.developer_user.user_name
}

output "developer_role_arn" {
  description = "ARN del role developer"
  value       = aws_iam_role.developer.arn
}

output "developer_role_name" {
  description = "Nombre del role developer"
  value       = aws_iam_role.developer.name
}

output "developer_access_key_id" {
  description = "Access Key ID del usuario developer"
  value       = module.developer_user.access_key_id
  sensitive   = true
}

output "developer_access_key_secret" {
  description = "Secret Access Key del usuario developer"
  value       = module.developer_user.access_key_secret
  sensitive   = true
}

output "account_id" {
  description = "ID de la cuenta AWS"
  value       = local.account_id
}

output "allowed_regions" {
  description = "Regiones permitidas"
  value       = var.allowed_regions
}

# ============================================
# foundation/iam/terraform.tfvars.example
# ============================================
# Copia este archivo a terraform.tfvars y completa los valores

aws_region = "eu-west-1"
environment = "dev"

# Tu nombre o email
lab_owner = "tu-nombre@example.com"

# Regiones donde puedes crear recursos
allowed_regions = ["eu-west-1", "eu-central-1"]

# Nombre del usuario IAM a crear
developer_username = "lab-developer"

# Centro de costos para tracking
cost_center = "personal-lab"

# Servicios permitidos (agregar según necesites)
allowed_services = [
  "ec2",
  "lambda",
  "s3",
  "vpc",
  "rds",
  "cloudformation",
  "cloudwatch",
  "logs"
]