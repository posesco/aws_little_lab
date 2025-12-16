variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "n8n"
}

variable "env" {
  type        = string
  description = "Environment (dev, staging, prod)"
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "Environment must be dev, staging, or prod."
  }
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
  type        = string
  description = "EC2 instance type"
  default     = "t4g.small"
}

variable "key_name" {
  type        = string
  description = "Name of the SSH key pair in AWS"
}

variable "lab_volume_size" {
  type        = number
  description = "Size of the root volume in GB"
  default     = 10
}

variable "cloudflare_tunnel_token" {
  type        = string
  description = "Cloudflare Tunnel token for cloudflared service"
  sensitive   = true
}
