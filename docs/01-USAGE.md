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

