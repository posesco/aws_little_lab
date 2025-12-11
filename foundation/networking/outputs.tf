output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  value       = aws_subnet.private[*].cidr_block
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "s3_endpoint_id" {
  description = "VPC Endpoint ID for S3"
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  description = "VPC Endpoint ID for DynamoDB"
  value       = aws_vpc_endpoint.dynamodb.id
}

output "default_security_group_id" {
  description = "Default Security Group ID"
  value       = aws_default_security_group.default.id
}

output "availability_zones" {
  description = "Availability zones used by subnets"
  value       = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))
}

