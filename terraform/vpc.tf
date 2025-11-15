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

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.lab_vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name    = "${var.project}-public-${count.index}"
    Tier    = "public"
    Project = var.project
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.lab_vpc.cidr_block, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name    = "${var.project}-private-${count.index}"
    Tier    = "private"
    Project = var.project
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab_vpc.id
  tags = { Name = "${var.project}-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.lab_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.project}-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

data "aws_availability_zones" "available" {
  state = "available"
}