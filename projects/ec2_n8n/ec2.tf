resource "aws_instance" "lab_instance" {
  ami                         = data.aws_ami.os.id
  instance_type               = var.instance_type[local.env]
  vpc_security_group_ids      = [aws_security_group.lab_sg.id]
  key_name                    = var.key_name[local.env]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/user_data.sh", {
    cloudflare_tunnel_token = var.cloudflare_tunnel_token[local.env]
  })
  subnet_id            = data.terraform_remote_state.networking.outputs.public_subnet_ids[0]
  iam_instance_profile = data.terraform_remote_state.iam.outputs.ec2_projects_instance_profile_name

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.lab_volume_size[local.env]
    encrypted   = true
    tags = merge(
      local.common_tags,
      {
        ResourceName = "${var.project}-${local.env}-disk"
        Component    = "storage"
      }
    )
  }
  tags = merge(
    local.common_tags,
    {
      ResourceName = "${var.project}-${local.env}-instance"
      Component    = "compute"
    }
  )
}