output "s3_state_bucket" {
  description = "S3 bucket for remote status"
  value       = aws_s3_bucket.tf_state.bucket
}

output "s3_state_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.tf_state.arn
}
