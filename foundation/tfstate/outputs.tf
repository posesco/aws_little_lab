output "s3_state_bucket" {
  description = "Bucket S3 creado para el state remoto"
  value       = aws_s3_bucket.tf_state.bucket
}

output "s3_state_bucket_arn" {
  description = "ARN del bucket S3 para backend"
  value       = aws_s3_bucket.tf_state.arn
}
