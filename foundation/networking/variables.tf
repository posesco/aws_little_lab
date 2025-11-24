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

