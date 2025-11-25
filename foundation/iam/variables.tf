variable "aws_region" {
  description = "Región principal de AWS"
  type        = string
  default     = "eu-west-1"
}

variable "Env" {
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

