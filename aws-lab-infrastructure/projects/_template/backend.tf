# ============================================
# projects/_template/backend.tf
# ============================================
terraform {
  backend "s3" {
    bucket         = "terraform-state-XXXXXXXXXX"  # Cambiar por el bucket creado
    key            = "projects/PROJECTNAME/terraform.tfstate"  # Se reemplaza automáticamente
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

# ============================================
# projects/_template/providers.tf
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

# Obtener outputs del foundation/iam para asumir role
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "terraform-state-XXXXXXXXXX"  # Cambiar por el bucket creado
    key    = "foundation/iam/terraform.tfstate"
    region = "eu-west-1"
  }
}

# Obtener outputs del foundation/networking
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "terraform-state-XXXXXXXXXX"  # Cambiar por el bucket creado
    key    = "foundation/networking/terraform.tfstate"
    region = "eu-west-1"
  }
}

# Provider principal con role assumption
provider "aws" {
  region = var.aws_region

  # Asumir el role developer
  assume_role {
    role_arn     = data.terraform_remote_state.iam.outputs.developer_role_arn
    session_name = "terraform-${var.project_name}"
  }

  default_tags {
    tags = module.common_tags.tags
  }
}

# ============================================
# projects/_template/main.tf
# ============================================
locals {
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  public_subnet_ids  = data.terraform_remote_state.networking.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
}

# Tags comunes
module "common_tags" {
  source = "../../modules/common-tags"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  additional_tags = {
    Project = var.project_name
  }
}

# ============================================
# Aquí va tu infraestructura específica
# ============================================

# Ejemplo: Security Group
resource "aws_security_group" "main" {
  name        = "${var.project_name}-sg"
  description = "Security group for ${var.project_name}"
  vpc_id      = local.vpc_id

  tags = merge(
    module.common_tags.tags,
    {
      Name = "${var.project_name}-sg"
    }
  )
}

# Regla de ingress ejemplo (SSH)
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.main.id

  description = "SSH access"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = var.allowed_ssh_cidr
}

# Regla de egress (permitir todo el tráfico saliente)
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.main.id

  description = "Allow all outbound"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# Ejemplo comentado: EC2 Instance
/*
module "ec2_instance" {
  source = "../../modules/ec2-instance"

  instance_name      = "${var.project_name}-server"
  instance_type      = "t3.micro"
  subnet_id          = local.public_subnet_ids[0]
  security_group_ids = [aws_security_group.main.id]
  key_name          = var.ssh_key_name

  tags = module.common_tags.tags
}
*/

# Ejemplo comentado: Lambda Function
/*
module "lambda_function" {
  source = "../../modules/lambda-function"

  function_name = "${var.project_name}-function"
  runtime       = "python3.11"
  handler       = "index.handler"
  source_dir    = "${path.module}/lambda"

  environment_variables = {
    ENVIRONMENT = var.environment
    PROJECT     = var.project_name
  }

  tags = module.common_tags.tags
}
*/

# Ejemplo comentado: S3 Bucket
/*
resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-${var.environment}-bucket"

  tags = merge(
    module.common_tags.tags,
    {
      Name = "${var.project_name}-bucket"
    }
  )
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
*/

# ============================================
# projects/_template/variables.tf
# ============================================
variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Nombre del proyecto (sin espacios, lowercase)"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Propietario del proyecto"
  type        = string
}

variable "cost_center" {
  description = "Centro de costos"
  type        = string
  default     = "personal-lab"
}

variable "allowed_ssh_cidr" {
  description = "CIDR permitido para SSH (ej: tu IP pública/32)"
  type        = string
  default     = "0.0.0.0/0" # ⚠️ Cambiar por tu IP para mayor seguridad
}

variable "ssh_key_name" {
  description = "Nombre de la SSH key pair existente en AWS"
  type        = string
  default     = null
}

# Variables específicas del proyecto
# Agregar aquí tus variables personalizadas

# ============================================
# projects/_template/outputs.tf
# ============================================
output "project_name" {
  description = "Nombre del proyecto"
  value       = var.project_name
}

output "vpc_id" {
  description = "ID de la VPC utilizada"
  value       = local.vpc_id
}

output "security_group_id" {
  description = "ID del Security Group principal"
  value       = aws_security_group.main.id
}

# Outputs específicos del proyecto
# Agregar aquí tus outputs personalizados

# ============================================
# projects/_template/terraform.tfvars.example
# ============================================
# Copia este archivo a terraform.tfvars y completa los valores

aws_region   = "eu-west-1"
project_name = "mi-proyecto"  # Cambiar por el nombre de tu proyecto
environment  = "dev"

# Propietario del proyecto
owner = "tu-nombre@example.com"

# Centro de costos
cost_center = "personal-lab"

# Tu IP pública para SSH (ej: 203.0.113.45/32)
# Obtén tu IP en: curl ifconfig.me
allowed_ssh_cidr = "0.0.0.0/0"  # ⚠️ Cambiar por tu IP

# Nombre de la SSH key (si usas EC2)
# Primero crea la key: aws ec2 create-key-pair --key-name lab-key --query 'KeyMaterial' --output text > lab-key.pem
ssh_key_name = null  # ej: "lab-key"

# ============================================
# Variables específicas de tu proyecto
# ============================================
# Agregar aquí configuraciones personalizadas