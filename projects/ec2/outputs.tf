output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.lab_instance.id
}

output "instance_public_ip" {
  description = "IP pública asignada automáticamente a la instancia"
  value       = aws_instance.lab_instance.public_ip
}

output "instance_public_dns" {
  description = "DNS público asignado automáticamente a la instancia"
  value       = aws_instance.lab_instance.public_dns
}


# output "s3_state_bucket" {
#   description = "Bucket S3 creado para el state remoto"
#   value       = aws_s3_bucket.tf_state.bucket
# }

# output "s3_state_bucket_arn" {
#   description = "ARN del bucket S3 para backend"
#   value       = aws_s3_bucket.tf_state.arn
# }
