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