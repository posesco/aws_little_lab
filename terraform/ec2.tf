data "aws_ami" "os" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "lab_instance" {
  ami                         = data.aws_ami.os.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.lab_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/user_data.sh")
  subnet_id                   = aws_subnet.public[0].id
  root_block_device {
      volume_type = "gp3"
      volume_size = var.lab_volume_size
      tags = {
        Name    = "${var.project}-lab-volume"
        Project = var.project
        Env     = var.env
        Owner   = var.owner
      }

  }
  tags = {
    Name    = "${var.project}-instance"
    Project = var.project
    Env     = var.env
    Owner   = var.owner
  }
}