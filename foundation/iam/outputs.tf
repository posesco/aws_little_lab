output "developer_user_arn" {
  description = "ARN del usuario developer"
  value       = module.developer_user.user_arn
}

output "developer_user_name" {
  description = "Nombre del usuario developer"
  value       = module.developer_user.user_name
}

output "developer_role_arn" {
  description = "ARN del role developer"
  value       = aws_iam_role.developer.arn
}

output "developer_role_name" {
  description = "Nombre del role developer"
  value       = aws_iam_role.developer.name
}

output "developer_access_key_id" {
  description = "Access Key ID del usuario developer"
  value       = module.developer_user.access_key_id
  sensitive   = true
}

output "developer_access_key_secret" {
  description = "Secret Access Key del usuario developer"
  value       = module.developer_user.access_key_secret
  sensitive   = true
}

output "account_id" {
  description = "ID de la cuenta AWS"
  value       = local.account_id
}

output "allowed_regions" {
  description = "Regiones permitidas"
  value       = var.allowed_regions
}

