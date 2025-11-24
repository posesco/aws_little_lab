## 02-NEW-PROJECT.md - Crear Nuevos Proyectos

### Método Rápido: Script Automatizado

```bash
cd scripts
chmod +x new-project.sh
./new-project.sh mi-nuevo-proyecto
```

Esto crea la estructura completa automáticamente.

### Método Manual

```bash
# Copiar template
cp -r projects/_template projects/mi-proyecto

# Actualizar backend.tf
cd projects/mi-proyecto
sed -i '' 's/PROJECTNAME/mi-proyecto/g' backend.tf

# Configurar variables
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

### Configurar el Proyecto

#### 1. Editar `terraform.tfvars`

```hcl
project_name     = "mi-proyecto-ec2"
environment      = "dev"
owner            = "tu-email@example.com"
allowed_ssh_cidr = "203.0.113.45/32"  # Tu IP pública
ssh_key_name     = "lab-key"
```

#### 2. Editar `main.tf` con tu Infraestructura

**Ejemplo: Servidor EC2 con Nginx**

```hcl
# Descomentar y configurar el módulo EC2
module "ec2_instance" {
  source = "../../modules/ec2-instance"

  instance_name      = "${var.project_name}-server"
  instance_type      = "t3.micro"
  subnet_id          = local.public_subnet_ids[0]
  security_group_ids = [aws_security_group.main.id]
  key_name          = var.ssh_key_name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
  EOF

  tags = module.common_tags.tags
}
```

**Ejemplo: API con Lambda + API Gateway**

```hcl
# Lambda function
module "api_lambda" {
  source = "../../modules/lambda-function"

  function_name = "${var.project_name}-api"
  runtime       = "python3.11"
  handler       = "index.handler"
  source_dir    = "${path.module}/lambda"

  environment_variables = {
    ENVIRONMENT = var.environment
  }

  tags = module.common_tags.tags
}

# API Gateway
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  tags = module.common_tags.tags
}
```

#### 3. Agregar Security Group Rules

```hcl
# HTTP
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.main.id

  description = "HTTP access"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

# HTTPS
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.main.id

  description = "HTTPS access"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}
```

### Desplegar el Proyecto

```bash
# Asumir role si no lo has hecho
cd ../../scripts
./assume-role.sh developer
source /tmp/assume-role-developer.sh

# Ir al proyecto
cd ../projects/mi-proyecto

# Inicializar
terraform init

# Ver plan
terraform plan

# Aplicar
terraform apply

# Ver outputs
terraform output
```

### Iterar en el Proyecto

```bash
# Hacer cambios en main.tf
vim main.tf

# Ver qué cambiará
terraform plan

# Aplicar cambios
terraform apply

# Si algo sale mal, rollback
terraform plan -out=previous.plan  # Antes de cambios
terraform apply previous.plan      # Para volver
```

### Destruir el Proyecto

```bash
cd projects/mi-proyecto
terraform destroy

# Opcional: eliminar carpeta
cd ..
rm -rf mi-proyecto
```

