variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "n8n"
}

variable "allowed_ssh_cidr_ipv4" {
  type        = string
  description = "CIDR block allowed for SSH access (IPv4)"
}

variable "allowed_ssh_cidr_ipv6" {
  type        = string
  description = "CIDR block allowed for SSH access (IPv6)"
}

variable "instance_type" {
  type        = map(string)
  description = "EC2 instance type"
  default = {
    dev     = "t4g.small"
    staging = "t4g.medium"
    prod    = "t4g.large"
  }
  validation {
    condition = alltrue([
      for value in values(var.instance_type) :
      can(regex("^[a-z][a-z0-9]*g[d]?\\.(nano|micro|small|medium|large|xlarge|[0-9]+xlarge)$", value))
    ])
    error_message = "Only ARM64 (Graviton) instance types allowed (e.g., t4g.small, m6g.large, c7gd.xlarge)."
  }
}

variable "key_name" {
  type        = map(string)
  description = "Name of the SSH key pair in AWS"
  default = {
    dev     = "keypair_dev"
    staging = "keypair_staging"
    prod    = "keypair_prod"
  }
  validation {
    condition     = alltrue([for value in values(var.key_name) : value != ""])
    error_message = "All key_name values must be non-empty strings."
  }
}

variable "lab_volume_size" {
  type        = map(number)
  description = "Size of the root volume in GB"
  default = {
    dev     = 10
    staging = 50
    prod    = 50
  }
  validation {
    condition     = alltrue([for value in values(var.lab_volume_size) : value > 10])
    error_message = "All lab_volume_size values must be greater than 10 GB."
  }
}

variable "cloudflare_tunnel_token" {
  type        = map(string)
  description = "Cloudflare Tunnel token for cloudflared service per environment"
  sensitive   = true
  default = {
    dev     = "token_dev_value"
    staging = "token_staging_value"
    prod    = "token_prod_value"
  }
  validation {
    condition     = alltrue([for value in values(var.cloudflare_tunnel_token) : value != ""])
    error_message = "All cloudflare_tunnel_token values must be non-empty strings."
  }
}