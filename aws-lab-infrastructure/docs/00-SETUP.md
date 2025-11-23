# Documentación AWS Lab Infrastructure

## 00-SETUP.md - Configuración Inicial

### Prerequisitos

1. **AWS CLI instalado y configurado**
```bash
aws --version
aws configure
# Ingresa tus credenciales de root o admin inicial
```

2. **Terraform instalado**
```bash
terraform --version
# Requerido: >= 1.6.0
```

3. **jq instalado** (para scripts)
```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq
```

4. **Git configurado**
```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

### Paso 1: Clonar o Crear el Repositorio

```bash
# Si es nuevo
mkdir aws-lab-infrastructure
cd aws-lab-infrastructure
git init

# Crear estructura de carpetas
mkdir -p foundation/{iam,networking,billing}/{policies,}
mkdir -p modules/{iam-user-with-mfa,iam-role-developer,common-tags,ec2-instance,lambda-function}
mkdir -p projects/_template
mkdir -p scripts
mkdir -p docs
```

### Paso 2: Configurar Backend Remoto

```bash
cd scripts
chmod +x setup-backend.sh
./setup-backend.sh
```

**Guarda los valores que imprime el script:**
- BUCKET_NAME
- DYNAMODB_TABLE
- REGION

**Actualiza todos los archivos `backend.tf`** con el nombre del bucket creado:
```bash
# Buscar y reemplazar
find . -name "backend.tf" -exec sed -i '' 's/terraform-state-XXXXXXXXXX/BUCKET_NAME_AQUI/g' {} \;
```

### Paso 3: Copiar Archivos del Proyecto

Copia todos los archivos de los artifacts a sus ubicaciones correspondientes según la estructura mostrada.

### Paso 4: Desplegar Foundation IAM

```bash
cd foundation/iam
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Editar con tus valores

# Inicializar Terraform
terraform init

# Ver plan
terraform plan

# Aplicar (crear usuario y roles)
terraform apply
```

**⚠️ IMPORTANTE: Guarda las credenciales que se imprimen:**
```bash
# Ver las credenciales (solo una vez)
terraform output developer_access_key_id
terraform output developer_access_key_secret
```

Guárdalas en tu gestor de contraseñas o archivo seguro.

### Paso 5: Configurar MFA

```bash
cd ../../scripts
chmod +x configure-mfa.sh
./configure-mfa.sh lab-developer
```

1. Se generará un código QR en `/tmp/lab-developer-qr.png`
2. Escanéalo con Google Authenticator o Authy
3. Ingresa dos códigos consecutivos cuando se soliciten

### Paso 6: Configurar AWS CLI con las Nuevas Credenciales

```bash
# Configurar profile para el usuario developer
aws configure --profile lab-developer
# AWS Access Key ID: <output de terraform>
# AWS Secret Access Key: <output de terraform>
# Default region: eu-west-1
# Default output format: json

# Probar
aws sts get-caller-identity --profile lab-developer
```

### Paso 7: Asumir Role Developer

```bash
cd scripts
chmod +x assume-role.sh
./assume-role.sh developer
```

Ingresa tu código MFA de 6 dígitos. Luego:

```bash
# Cargar credenciales temporales
source /tmp/assume-role-developer.sh

# Verificar que asumiste el role
aws sts get-caller-identity
# Debería mostrar: arn:aws:sts::ACCOUNT:assumed-role/developer-role/...
```

### Paso 8: Desplegar Networking

```bash
cd ../foundation/networking
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

terraform init
terraform plan
terraform apply
```

### Paso 9: Configurar Billing Alerts

```bash
cd ../billing
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Configura tu email y límite

terraform init
terraform apply
```

**⚠️ Confirma la suscripción de email** que recibirás en tu inbox.

---

## 01-USAGE.md - Uso Diario

### Workflow Típico

#### 1. Iniciar Sesión con MFA

```bash
cd scripts
./assume-role.sh developer
source /tmp/assume-role-developer.sh

# Verificar
aws sts get-caller-identity
```

**Las credenciales temporales duran 12 horas.**

#### 2. Trabajar en Foundation

```bash
# IAM: Agregar nuevo usuario o modificar permisos
cd foundation/iam
vim users.tf  # O el archivo que necesites
terraform plan
terraform apply

# Networking: Modificar VPC
cd foundation/networking
terraform plan
terraform apply
```

#### 3. Ver Información de Foundation

```bash
# Ver outputs de IAM
cd foundation/iam
terraform output

# Ver outputs de Networking
cd ../networking
terraform output
```

### Comandos Útiles

#### Listar Recursos

```bash
# Ver todos los recursos de un componente
terraform state list

# Ver detalles de un recurso
terraform state show aws_iam_role.developer
```

#### Actualizar Estado

```bash
# Refrescar estado sin modificar recursos
terraform refresh

# Importar recurso existente
terraform import aws_instance.example i-1234567890abcdef0
```

#### Destruir Recursos

```bash
# Destruir recurso específico
terraform destroy -target=aws_instance.test

# Destruir todo el componente
terraform destroy
```

---

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

---

## 03-COST-OPTIMIZATION.md - Optimización de Costos

### Servicios Más Costosos

#### 1. NAT Gateway (~32 EUR/mes por AZ)

**Problema**: Permite salida a Internet desde subnets privadas.

**Solución**: Usa VPC Endpoints (GRATIS) para S3 y DynamoDB.

```hcl
# Ya incluido en foundation/networking
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.eu-west-1.s3"
}
```

**Alternativa**: NAT Instance (t4g.nano ~3 EUR/mes) si realmente necesitas NAT.

#### 2. RDS/Aurora

**Problema**: Instancias siempre encendidas consumen todo el mes.

**Solución 1**: Aurora Serverless v2 con auto-pause
```hcl
resource "aws_rds_cluster" "this" {
  engine_mode = "provisioned"
  engine      = "aurora-postgresql"

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 1.0
  }
}
```

**Solución 2**: Usar RDS con auto-stop/start
```bash
# Script para detener RDS al terminar el día
aws rds stop-db-instance --db-instance-identifier mi-db
```

#### 3. EC2 Instances

**Problema**: Instancias corriendo 24/7.

**Solución 1**: Usar t3.micro (Free Tier 750h/mes el primer año)

**Solución 2**: Detener instancias cuando no las uses
```bash
# Script de auto-stop nocturno
aws ec2 stop-instances --instance-ids i-1234567890abcdef0
```

**Solución 3**: Spot Instances (hasta 90% descuento)
```hcl
resource "aws_instance" "this" {
  instance_market_options {
    market_type = "spot"
  }
}
```

#### 4. EBS Snapshots

**Problema**: Snapshots antiguos acumulan costo.

**Solución**: Lifecycle policy para eliminar snapshots antiguos
```bash
aws ec2 describe-snapshots --owner-ids self \
  --query 'Snapshots[?StartTime<=`2024-01-01`].[SnapshotId]' \
  --output text | xargs -n 1 aws ec2 delete-snapshot --snapshot-id
```

### Estrategias de Ahorro

#### 1. Usar Free Tier

Servicios gratuitos (12 meses):
- EC2: 750h/mes de t2.micro o t3.micro
- RDS: 750h/mes de db.t2.micro, db.t3.micro o db.t4g.micro
- S3: 5GB de almacenamiento
- Lambda: 1M requests/mes, 400,000 GB-segundos

#### 2. Tags para Tracking

```hcl
tags = {
  CostCenter  = "personal-lab"
  Project     = "mi-proyecto"
  Environment = "dev"
  AutoStop    = "true"  # Para automatización
}
```

Luego filtra costos por tag:
```bash
aws ce get-cost-and-usage \
  --filter file://<(echo '{"Tags":{"Key":"Project","Values":["mi-proyecto"]}}')
```

#### 3. Budget Alerts Configuradas

Ya incluidas en `foundation/billing`:
- Alerta al 80% del límite
- Alerta al 90%
- Alerta al 100%
- Pronóstico si se va a superar

#### 4. Usar Regiones Baratas

Costos por región (ejemplo EC2 t3.micro):
- us-east-1: $0.0104/hora
- eu-west-1: $0.0114/hora (9% más caro)
- ap-southeast-1: $0.0132/hora (27% más caro)

Para laboratorio: `us-east-1` o `eu-west-1` son buenas opciones.

### Revisar Costos Regularmente

```bash
# Script incluido
cd scripts
./cost-report.sh

# O manualmente
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

### Checklist Semanal

```bash
# 1. Ver recursos activos
aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`].[InstanceId,InstanceType,Tags[?Key==`Name`].Value|[0]]' --output table

# 2. Ver RDS activos
aws rds describe-db-instances --query 'DBInstances[?DBInstanceStatus==`available`].[DBInstanceIdentifier,DBInstanceClass]' --output table

# 3. Ver snapshots antiguos
aws ec2 describe-snapshots --owner-ids self --query 'Snapshots[?StartTime<=`2024-01-01`].[SnapshotId,StartTime,VolumeSize]' --output table

# 4. Ver volúmenes no adjuntos
aws ec2 describe-volumes --filters Name=status,Values=available --query 'Volumes[].[VolumeId,Size,CreateTime]' --output table
```

---

## 04-TROUBLESHOOTING.md - Solución de Problemas

### Problemas Comunes

#### 1. Error: "AccessDenied" al ejecutar Terraform

**Síntomas**:
```
Error: creating EC2 Instance: UnauthorizedOperation
```

**Causas**:
1. No asumiste el role developer
2. MFA expiró
3. Región no permitida
4. Falta permiso específico

**Soluciones**:

```bash
# Verificar identidad actual
aws sts get-caller-identity

# Si ves tu usuario base, asume el role
cd scripts
./assume-role.sh developer
source /tmp/assume-role-developer.sh

# Verificar de nuevo
aws sts get-caller-identity
# Debe mostrar: arn:aws:sts::ACCOUNT:assumed-role/developer-role/...
```

#### 2. Error: "Backend initialization required"

**Síntomas**:
```
Error: Backend initialization required
```

**Solución**:
```bash
terraform init -reconfigure
```

#### 3. Error: MFA token inválido

**Síntomas**:
```
Error: AccessDenied: MultiFactorAuthentication failed
```

**Causas**:
1. Código MFA incorrecto
2. Reloj del sistema desincronizado

**Soluciones**:

```bash
# Sincronizar reloj (macOS)
sudo sntp -sS time.apple.com

# Linux
sudo ntpdate pool.ntp.org

# Intentar de nuevo
./assume-role.sh developer
```

#### 4. Error: "State lock"

**Síntomas**:
```
Error: Error acquiring the state lock
```

**Causa**: Terraform se interrumpió y dejó el lock.

**Solución**:
```bash
# Ver el lock ID en el mensaje de error
terraform force-unlock LOCK_ID
```

#### 5. Error: Tags obligatorios faltantes

**Síntomas**:
```
Error: creating EC2 Instance: TagPolicyViolation
```

**Causa**: La política IAM requiere tags `Project`, `Environment`, `Owner`.

**Solución**:

```hcl
# Usar el módulo common-tags
module "common_tags" {
  source = "../../modules/common-tags"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
}

# Aplicar a recursos
resource "aws_instance" "this" {
  # ...
  tags = module.common_tags.tags
}
```

#### 6. Error: Región no permitida

**Síntomas**:
```
Error: UnauthorizedOperation: You are not authorized to perform this operation in region us-west-2
```

**Causa**: Solo `eu-west-1` y `eu-central-1` permitidas por defecto.

**Solución**:

```bash
# Agregar región a foundation/iam
cd foundation/iam
vim variables.tf

# Modificar allowed_regions
variable "allowed_regions" {
  default = ["eu-west-1", "eu-central-1", "us-west-2"]
}

terraform apply
```

#### 7. Costo Excedido

**Síntomas**: Recibes email de alerta de presupuesto.

**Acciones**:

```bash
# 1. Ver costos actuales
cd scripts
./cost-report.sh

# 2. Identificar recursos costosos
aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`]' --output table

# 3. Detener recursos innecesarios
aws ec2 stop-instances --instance-ids i-XXXXX

# 4. Eliminar snapshots antiguos
aws ec2 describe-snapshots --owner-ids self --output table
aws ec2 delete-snapshot --snapshot-id snap-XXXXX

# 5. Destruir proyectos no usados
cd projects/proyecto-antiguo
terraform destroy
```

### Debugging Terraform

#### Ver Plan Detallado

```bash
terraform plan -out=plan.tfplan
terraform show plan.tfplan
```

#### Ver Estado Actual

```bash
# Listar recursos
terraform state list

# Ver recurso específico
terraform state show aws_instance.example

# Ver todo el estado
terraform show
```

#### Logs de Debug

```bash
export TF_LOG=DEBUG
terraform apply
unset TF_LOG
```

#### Verificar Sintaxis

```bash
terraform fmt -check
terraform validate
```

### Recuperación de Desastres

#### Backup del Estado

```bash
# El estado ya está en S3 con versionado
# Para descargar backup local
aws s3 cp s3://BUCKET/foundation/iam/terraform.tfstate ./backup.tfstate

# Ver versiones anteriores
aws s3api list-object-versions --bucket BUCKET --prefix foundation/iam/terraform.tfstate
```

#### Restaurar Estado Anterior

```bash
# Descargar versión específica
aws s3api get-object \
  --bucket BUCKET \
  --key foundation/iam/terraform.tfstate \
  --version-id VERSION_ID \
  terraform.tfstate

# Usar estado local temporalmente
terraform init -reconfigure -backend=false
```

#### Recrear Infraestructura

```bash
# Si perdiste todo el estado
cd foundation/iam
terraform init
terraform import aws_iam_user.developer lab-developer
terraform import aws_iam_role.developer developer-role
```

### Contactos de Soporte

- AWS Support: https://console.aws.amazon.com/support
- Terraform Issues: https://github.com/hashicorp/terraform/issues
- Documentación AWS: https://docs.aws.amazon.com