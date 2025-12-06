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