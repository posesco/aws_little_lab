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

