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

variable "budget_limit_euros" {
  description = "Límite mensual de presupuesto en EUR"
  type        = number
  default     = 15
}

variable "alert_emails" {
  description = "Emails para recibir alertas de presupuesto"
  type        = list(string)
}

variable "alert_thresholds" {
  description = "Porcentajes para alertas (ej: [80, 90, 100])"
  type        = list(number)
  default     = [80, 90, 100]
}

variable "lab_owner" {
  description = "Propietario del laboratorio"
  type        = string
}
