Monorepo de Infrastructure as Code (IaC) usando Terraform para gestionar un laboratorio personal de AWS con múltiples proyectos independientes.

## 🏗️ Arquitectura

```
Foundation Layer (permanente)
├── IAM: Usuarios, Roles, Políticas
├── Networking: VPC Compartido
└── Billing: Alertas de Costos

Projects Layer (experimental)
├── proyecto1-ec2-nginx
├── proyecto2-lambda-api
└── proyecto3-data-pipeline
```

## 🚀 Quick Start

### 1. Configurar Backend Remoto

```bash
cd scripts
./setup-backend.sh
```

Esto creará:
- Bucket S3 para estados Terraform
- Tabla DynamoDB para state locking
- Versionado y encriptación habilitados

### 2. Desplegar Foundation (IAM)

```bash
cd foundation/iam
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus valores
terraform init
terraform plan
terraform apply
```

**IMPORTANTE**: Guarda las credenciales del usuario que se crean.

### 3. Configurar MFA

```bash
cd ../../scripts
./configure-mfa.sh <IAM_USERNAME>
```

### 4. Desplegar Networking

```bash
cd ../foundation/networking
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

### 5. Configurar Billing Alerts

```bash
cd ../billing
cp terraform.tfvars.example terraform.tfvars
# Configura tu email y límite de presupuesto
terraform init
terraform apply
```

### 6. Crear Primer Proyecto

```bash
cd ../../scripts
./new-project.sh mi-proyecto-ec2
cd ../projects/mi-proyecto-ec2
cp terraform.tfvars.example terraform.tfvars
# Editar configuración
terraform init
terraform apply
```

## 📁 Estructura del Proyecto

```
aws-lab-infrastructure/
├── foundation/           # Infraestructura permanente
│   ├── iam/             # Usuarios, roles, políticas
│   ├── networking/      # VPC compartido
│   └── billing/         # Alertas de costos
├── modules/             # Módulos reutilizables
├── projects/            # Proyectos experimentales
│   ├── _template/       # Template base
│   └── proyecto-*/      # Tus proyectos
├── scripts/             # Scripts de ayuda
└── docs/                # Documentación detallada
```

## 🔐 Modelo de Seguridad

### AssumeRole Pattern

Este proyecto usa el patrón **AssumeRole** recomendado por AWS:

1. **Usuario Base**: Permisos mínimos + MFA habilitado
2. **Roles IAM**: Permisos específicos por función
3. **Credenciales Temporales**: Expiran automáticamente

### Asumir un Role

```bash
cd scripts
./assume-role.sh developer
# Esto configura credenciales temporales
# Válidas por 12 horas
```

### Permisos del Role Developer

- **Servicios**: EC2, Lambda, S3, VPC, RDS, Aurora
- **Regiones**: eu-west-1, eu-central-1
- **Restricciones**: MFA requerido, tags obligatorios

## 💰 Control de Costos

### Budget Alert Configurado

- Límite: 15 EUR/mes (configurable)
- Alertas: 80%, 90%, 100%
- Email de notificación

### Recursos Cost-Optimized

- ✅ VPC compartido (evita múltiples NAT Gateways)
- ✅ Sin NAT Gateway (usa VPC Endpoints)
- ✅ RDS/Aurora con auto-pause
- ✅ Tags obligatorios para tracking

### Revisar Costos

```bash
cd scripts
./cost-report.sh
```

## 📚 Documentación

- [00-SETUP.md](docs/00-SETUP.md) - Configuración inicial detallada
- [01-USAGE.md](docs/01-USAGE.md) - Uso diario del proyecto
- [02-NEW-PROJECT.md](docs/02-NEW-PROJECT.md) - Crear nuevos proyectos
- [03-COST-OPTIMIZATION.md](docs/03-COST-OPTIMIZATION.md) - Optimización de costos
- [04-TROUBLESHOOTING.md](docs/04-TROUBLESHOOTING.md) - Solución de problemas

## 🛠️ Comandos Útiles

### Foundation

```bash
# Ver estado del IAM
cd foundation/iam && terraform state list

# Ver outputs (ARNs de roles)
terraform output

# Actualizar políticas
terraform apply -target=aws_iam_role_policy_attachment.developer_policies
```

### Projects

```bash
# Listar proyectos activos
ls -la projects/

# Destruir proyecto experimental
cd projects/proyecto-prueba
terraform destroy

# Ver recursos de un proyecto
terraform state list
```

## 🔄 Workflow Típico

```bash
# 1. Asumir role developer
./scripts/assume-role.sh developer

# 2. Crear nuevo proyecto
./scripts/new-project.sh mi-api-lambda

# 3. Configurar proyecto
cd projects/mi-api-lambda
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

# 4. Desplegar
terraform init
terraform plan
terraform apply

# 5. Experimentar...

# 6. Cuando termines, destruir
terraform destroy
```

## ⚠️ Notas Importantes

### Estados Terraform

Cada componente tiene su **estado independiente**:
- `foundation/iam` → S3: `foundation/iam/terraform.tfstate`
- `projects/proyecto1` → S3: `projects/proyecto1/terraform.tfstate`

**Puedes destruir proyectos sin afectar foundation.**

### Regiones Permitidas

Por defecto: `eu-west-1`, `eu-central-1`

Para agregar regiones:
```bash
cd foundation/iam
vim variables.tf  # Agregar región a allowed_regions
terraform apply
```

### MFA Obligatorio

Los roles requieren MFA. Si recibes `Access Denied`:
1. Verifica que MFA esté configurado
2. Usa `assume-role.sh` para obtener credenciales con MFA

## 🐛 Troubleshooting

### Error: "AccessDenied"
```bash
# Verifica que asumiste el role
aws sts get-caller-identity

# Debería mostrar el role ARN, no tu usuario
```

### Error: "Backend initialization required"
```bash
terraform init -reconfigure
```

### Ver costos actuales
```bash
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

## 📞 Soporte

Para problemas o mejoras:
1. Revisar [docs/04-TROUBLESHOOTING.md](docs/04-TROUBLESHOOTING.md)
2. Buscar en logs de Terraform
3. Verificar permisos IAM

## 📄 Licencia

Proyecto personal de laboratorio. Usa bajo tu responsabilidad.

---

**Autor**: Tu nombre  
**Última actualización**: 2024  
**Versión Terraform**: >= 1.6.0