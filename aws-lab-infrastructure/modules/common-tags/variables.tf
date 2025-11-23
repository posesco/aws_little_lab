variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "owner" {
  description = "Propietario del recurso"
  type        = string
}

variable "cost_center" {
  description = "Centro de costos"
  type        = string
  default     = "lab"
}

variable "additional_tags" {
  description = "Tags adicionales"
  type        = map(string)
  default     = {}
}

