resource "aws_security_group" "lab_sg" {
  name        = "${var.project}-${var.env}-sg"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  tags = merge(
    local.common_tags,
    {
      ResourceName = "${var.project}-${var.env}-sg"
      Component    = "security"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.lab_sg.id
  cidr_ipv4         = var.allowed_ssh_cidr_ipv4
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
  security_group_id = aws_security_group.lab_sg.id
  cidr_ipv6         = var.allowed_ssh_cidr_ipv6
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.lab_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.lab_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

