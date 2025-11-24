resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project}-vpc"
    Project = var.project
    Env     = var.env
    Owner   = var.owner
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab_vpc.id
  tags = { Name = "${var.project}-igw" }
}


data "aws_availability_zones" "available" {
  state = "available"
}