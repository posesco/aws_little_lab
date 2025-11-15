resource "aws_security_group" "lab_sg" {
  name        = "${var.project}-sg"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.lab_vpc.id

  tags = {
    Name    = "${var.project}-sg"
    Project = var.project
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.lab_sg.id
  cidr_ipv4         = var.allowed_ssh_cidr_ipv4
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_no_tls_ipv4" {
  security_group_id = aws_security_group.lab_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.lab_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.lab_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
