resource "aws_instance" "lab_instance" {
  ami                         = data.aws_ami.os.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.lab_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/user_data.sh")
  subnet_id                   = data.terraform_remote_state.networking.outputs.public_subnet_ids[0]
  iam_instance_profile        = data.terraform_remote_state.iam.outputs.ec2_projects_instance_profile_name

  root_block_device {
    volume_type = "gp3"
    volume_size = var.lab_volume_size
    tags = merge(
      local.common_tags,
      {
        ResourceName = "${var.project}-${var.env}-disk"
        Component    = "storage"
      }
    )
  }
  tags = merge(
    local.common_tags,
    {
      ResourceName = "${var.project}-${var.env}-instance"
      Component    = "compute"
    }
  )
}