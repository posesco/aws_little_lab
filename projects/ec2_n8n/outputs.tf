output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.lab_instance.id
}

output "instance_public_ip" {
  description = "Public IP assigned to the instance"
  value       = aws_instance.lab_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS assigned to the instance"
  value       = aws_instance.lab_instance.public_dns
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.lab_sg.id
}
