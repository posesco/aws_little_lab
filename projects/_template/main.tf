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

