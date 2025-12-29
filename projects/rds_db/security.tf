resource "aws_security_group" "rds" {
  name        = "${var.project}-${local.env}-rds-sg"
  description = "Security group for RDS PostgreSQL - allows access from EC2 instances"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  tags = merge(
    local.common_tags,
    {
      ResourceName = "${var.project}-${local.env}-rds-sg"
      Component    = "security"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "allow_postgres_from_n8n" {
  security_group_id            = aws_security_group.rds.id
  description                  = "Allow PostgreSQL access from n8n EC2 instances"
  referenced_security_group_id = data.terraform_remote_state.ec2_n8n.outputs.security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}
