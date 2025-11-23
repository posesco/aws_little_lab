# ============================================
# modules/iam-user-with-mfa/main.tf
# ============================================
resource "aws_iam_user" "this" {
  name = var.username
  path = var.path
  tags = var.tags
}

resource "aws_iam_user_login_profile" "this" {
  count = var.create_console_password ? 1 : 0

  user                    = aws_iam_user.this.name
  password_reset_required = var.password_reset_required
}

resource "aws_iam_access_key" "this" {
  count = var.create_access_key ? 1 : 0
  user  = aws_iam_user.this.name
}

# Política que permite al usuario gestionar su propio MFA
resource "aws_iam_user_policy" "manage_own_mfa" {
  name = "${var.username}-manage-mfa"
  user = aws_iam_user.this.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowManageOwnMFA"
        Effect = "Allow"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:ResyncMFADevice",
          "iam:DeleteVirtualMFADevice"
        ]
        Resource = [
          "arn:aws:iam::*:mfa/$${aws:username}",
          "arn:aws:iam::*:user/$${aws:username}"
        ]
      },
      {
        Sid    = "AllowListMFADevices"
        Effect = "Allow"
        Action = [
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices"
        ]
        Resource = "*"
      }
    ]
  })
}

# Política que permite asumir roles con MFA
resource "aws_iam_user_policy" "assume_role_with_mfa" {
  count = length(var.assumable_role_arns) > 0 ? 1 : 0

  name = "${var.username}-assume-roles"
  user = aws_iam_user.this.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AssumeRolesWithMFA"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = var.assumable_role_arns
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })
}

# ============================================
# modules/iam-user-with-mfa/variables.tf
# ============================================
variable "username" {
  description = "Nombre del usuario IAM"
  type        = string
}

variable "path" {
  description = "Path del usuario IAM"
  type        = string
  default     = "/"
}

variable "create_console_password" {
  description = "Crear contraseña de consola"
  type        = bool
  default     = false
}

variable "password_reset_required" {
  description = "Requerir cambio de contraseña en primer login"
  type        = bool
  default     = true
}

variable "create_access_key" {
  description = "Crear access key para el usuario"
  type        = bool
  default     = true
}

variable "assumable_role_arns" {
  description = "ARNs de roles que el usuario puede asumir"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags para el usuario"
  type        = map(string)
  default     = {}
}

# ============================================
# modules/iam-user-with-mfa/outputs.tf
# ============================================
output "user_arn" {
  description = "ARN del usuario IAM"
  value       = aws_iam_user.this.arn
}

output "user_name" {
  description = "Nombre del usuario IAM"
  value       = aws_iam_user.this.name
}

output "access_key_id" {
  description = "Access Key ID"
  value       = var.create_access_key ? aws_iam_access_key.this[0].id : null
  sensitive   = true
}

output "access_key_secret" {
  description = "Secret Access Key"
  value       = var.create_access_key ? aws_iam_access_key.this[0].secret : null
  sensitive   = true
}

output "console_password" {
  description = "Contraseña de consola"
  value       = var.create_console_password ? aws_iam_user_login_profile.this[0].password : null
  sensitive   = true
}

# ============================================
# modules/iam-role-developer/main.tf
# ============================================
data "aws_caller_identity" "current" {}

# Role IAM
resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  max_session_duration = var.max_session_duration
  tags               = var.tags
}

# Trust policy: permite a usuarios asumir el role con MFA
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.trusted_user_arns
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "aws:MultiFactorAuthAge"
      values   = [var.mfa_age]
    }
  }
}

# Adjuntar políticas personalizadas desde archivos JSON
resource "aws_iam_role_policy" "custom_policies" {
  for_each = var.policy_files

  name   = each.key
  role   = aws_iam_role.this.id
  policy = file(each.value)
}

# Políticas AWS administradas (opcional)
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# ============================================
# modules/iam-role-developer/variables.tf
# ============================================
variable "role_name" {
  description = "Nombre del role IAM"
  type        = string
}

variable "trusted_user_arns" {
  description = "ARNs de usuarios que pueden asumir el role"
  type        = list(string)
}

variable "policy_files" {
  description = "Mapa de políticas personalizadas (nombre => path al archivo JSON)"
  type        = map(string)
  default     = {}
}

variable "managed_policy_arns" {
  description = "ARNs de políticas AWS administradas"
  type        = list(string)
  default     = []
}

variable "max_session_duration" {
  description = "Duración máxima de la sesión en segundos"
  type        = number
  default     = 43200 # 12 horas
}

variable "mfa_age" {
  description = "Edad máxima del token MFA en segundos"
  type        = number
  default     = 43200 # 12 horas
}

variable "tags" {
  description = "Tags para el role"
  type        = map(string)
  default     = {}
}

# ============================================
# modules/iam-role-developer/outputs.tf
# ============================================
output "role_arn" {
  description = "ARN del role IAM"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Nombre del role IAM"
  value       = aws_iam_role.this.name
}

output "role_id" {
  description = "ID del role IAM"
  value       = aws_iam_role.this.id
}

# ============================================
# modules/ec2-instance/main.tf
# ============================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "this" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name              = var.key_name

  user_data = var.user_data

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.delete_volume_on_termination
    encrypted             = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2
    http_put_response_hop_limit = 1
  }

  tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )
}

# ============================================
# modules/ec2-instance/variables.tf
# ============================================
variable "instance_name" {
  description = "Nombre de la instancia EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "ID de AMI (si está vacío, usa Ubuntu 22.04 LTS)"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "ID de subnet donde lanzar la instancia"
  type        = string
}

variable "security_group_ids" {
  description = "IDs de security groups"
  type        = list(string)
}

variable "key_name" {
  description = "Nombre de la SSH key pair"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Tamaño del volumen root en GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Tipo de volumen root"
  type        = string
  default     = "gp3"
}

variable "delete_volume_on_termination" {
  description = "Eliminar volumen al terminar instancia"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags para la instancia"
  type        = map(string)
  default     = {}
}

# ============================================
# modules/ec2-instance/outputs.tf
# ============================================
output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.this.id
}

output "instance_public_ip" {
  description = "IP pública de la instancia"
  value       = aws_instance.this.public_ip
}

output "instance_private_ip" {
  description = "IP privada de la instancia"
  value       = aws_instance.this.private_ip
}

output "instance_arn" {
  description = "ARN de la instancia"
  value       = aws_instance.this.arn
}

# ============================================
# modules/lambda-function/main.tf
# ============================================
data "archive_file" "lambda_zip" {
  count       = var.source_dir != "" ? 1 : 0
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "this" {
  filename         = var.source_dir != "" ? data.archive_file.lambda_zip[0].output_path : var.zip_file_path
  function_name    = var.function_name
  role            = aws_iam_role.lambda_exec.arn
  handler         = var.handler
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size
  source_code_hash = var.source_dir != "" ? data.archive_file.lambda_zip[0].output_base64sha256 : filebase64sha256(var.zip_file_path)

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.subnet_ids != null ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  tags = var.tags
}

# IAM role para Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

# Política básica de ejecución
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Política VPC (si se usa VPC)
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count      = var.subnet_ids != null ? 1 : 0
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# ============================================
# modules/lambda-function/variables.tf
# ============================================
variable "function_name" {
  description = "Nombre de la función Lambda"
  type        = string
}

variable "handler" {
  description = "Handler de la función"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Runtime de Lambda"
  type        = string
  default     = "python3.11"
}

variable "timeout" {
  description = "Timeout en segundos"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Memoria en MB"
  type        = number
  default     = 128
}

variable "source_dir" {
  description = "Directorio con código fuente (se creará ZIP automático)"
  type        = string
  default     = ""
}

variable "zip_file_path" {
  description = "Path a archivo ZIP existente"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Variables de entorno"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "IDs de subnets (si Lambda va en VPC)"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "IDs de security groups (si Lambda va en VPC)"
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "Tags para la función Lambda"
  type        = map(string)
  default     = {}
}

# ============================================
# modules/lambda-function/outputs.tf
# ============================================
output "function_arn" {
  description = "ARN de la función Lambda"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Nombre de la función Lambda"
  value       = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "ARN de invocación"
  value       = aws_lambda_function.this.invoke_arn
}

output "role_arn" {
  description = "ARN del role de ejecución"
  value       = aws_iam_role.lambda_exec.arn
}