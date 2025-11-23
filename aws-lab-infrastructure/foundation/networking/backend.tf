# ============================================
# foundation/networking/backend.tf
# ============================================
terraform {
  backend "s3" {
    bucket         = "terraform-state-XXXXXXXXXX"  # Cambiar por el bucket creado
    key            = "foundation/networking/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

# ============================================
# foundation/networking/providers.tf
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
      Component   = "foundation-networking"
    }
  }
}

# ============================================
# foundation/networking/variables.tf
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

variable "vpc_cidr" {
  description = "CIDR block para VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs para las subnets"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs para subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs para subnets privadas"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway (COSTO: ~32 EUR/mes)"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Habilitar VPN Gateway"
  type        = bool
  default     = false
}

variable "lab_owner" {
  description = "Propietario del laboratorio"
  type        = string
}

# ============================================
# foundation/networking/main.tf
# ============================================
locals {
  common_tags = {
    ManagedBy   = "Terraform"
    Environment = var.environment
    Owner       = var.lab_owner
    Component   = "shared-networking"
  }
}

# ============================================
# foundation/networking/vpc.tf
# ============================================

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-shared-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-igw"
    }
  )
}

# VPC Endpoints para S3 (Gratis, evita NAT Gateway)
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-s3-endpoint"
    }
  )
}

# VPC Endpoint para DynamoDB (Gratis)
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-dynamodb-endpoint"
    }
  )
}

# ============================================
# foundation/networking/subnets.tf
# ============================================

# Subnets públicas
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-public-subnet-${count.index + 1}"
      Type = "Public"
      Tier = "public"
    }
  )
}

# Subnets privadas
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-private-subnet-${count.index + 1}"
      Type = "Private"
      Tier = "private"
    }
  )
}

# Route Table para subnets públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-public-rt"
    }
  )
}

# Asociar route table a subnets públicas
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table para subnets privadas
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-private-rt"
    }
  )
}

# Asociar route table a subnets privadas
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Asociar VPC Endpoints a route tables
resource "aws_vpc_endpoint_route_table_association" "s3_public" {
  route_table_id  = aws_route_table.public.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_private" {
  route_table_id  = aws_route_table.private.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_public" {
  route_table_id  = aws_route_table.public.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_private" {
  route_table_id  = aws_route_table.private.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}

# NAT Gateway (OPCIONAL - COSTO: ~32 EUR/mes)
# Solo descomentar si realmente necesitas conectividad saliente desde subnets privadas
/*
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-nat-gateway"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[0].id
}
*/

# Default Security Group (Restringido)
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # No ingress rules (denegar todo por defecto)
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-default-sg"
    }
  )
}

# ============================================
# foundation/networking/outputs.tf
# ============================================
output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR de la VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs de subnets públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs de subnets privadas"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDRs de subnets públicas"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDRs de subnets privadas"
  value       = aws_subnet.private[*].cidr_block
}

output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "s3_endpoint_id" {
  description = "ID del VPC Endpoint para S3"
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  description = "ID del VPC Endpoint para DynamoDB"
  value       = aws_vpc_endpoint.dynamodb.id
}

output "default_security_group_id" {
  description = "ID del Security Group por defecto"
  value       = aws_default_security_group.default.id
}

# ============================================
# foundation/networking/terraform.tfvars.example
# ============================================
# Copia este archivo a terraform.tfvars y completa los valores

aws_region  = "eu-west-1"
environment = "dev"

# Propietario del laboratorio
lab_owner = "tu-nombre@example.com"

# CIDR de la VPC
vpc_cidr = "10.0.0.0/16"

# Availability Zones
availability_zones = ["eu-west-1a", "eu-west-1b"]

# Subnets públicas (con acceso a Internet)
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]

# Subnets privadas (sin acceso directo a Internet)
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# NAT Gateway: false = sin costo, true = ~32 EUR/mes
# Solo activar si realmente necesitas conectividad saliente desde subnets privadas
enable_nat_gateway = false

# VPN Gateway: false por defecto
enable_vpn_gateway = false