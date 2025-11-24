output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR de la VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs de subnets públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs de subnets privadas"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDRs de subnets públicas"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDRs de subnets privadas"
  value       = aws_subnet.private[*].cidr_block
}

output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "s3_endpoint_id" {
  description = "ID del VPC Endpoint para S3"
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  description = "ID del VPC Endpoint para DynamoDB"
  value       = aws_vpc_endpoint.dynamodb.id
}

output "default_security_group_id" {
  description = "ID del Security Group por defecto"
  value       = aws_default_security_group.default.id
}

