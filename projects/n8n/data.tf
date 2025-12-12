data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-unique-posesco"
    key    = "foundation/networking/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

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
