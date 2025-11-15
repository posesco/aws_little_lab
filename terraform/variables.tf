variable "aws_region" {
  type    = string
  default = ""
}

variable "aws_profile" {
  type    = string
  default = ""
}

variable "project" {
  type    = string
  default = "aws-lab"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "owner" {
  type    = string
  default = ""
}

variable "allowed_ssh_cidr_ipv4" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = ""
}

variable "key_name" {
  type        = string
  default     = ""
}

variable "state_bucket_name" {
  type        = string
  default     = "terraform-state-bucket-unique-posesco"
}

variable "workspace_key_prefix" {
  type    = string
  default = "workspaces"
}

variable "domain_name" {
  type    = string
  default = ""
}

variable "lab_volume_size" {
  type        = number
  default     = 10
}
