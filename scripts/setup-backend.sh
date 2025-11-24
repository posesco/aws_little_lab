#!/bin/bash
# ============================================
# scripts/setup-backend.sh
# ============================================
set -e

BUCKET_NAME="terraform-state-$(date +%s)"
DYNAMODB_TABLE="terraform-state-lock"
REGION="eu-west-1"

echo "🚀 Configurando Backend Remoto de Terraform"
echo "============================================"

# Verificar AWS CLI
if ! command -v aws &> /dev/null; then
    echo "❌ Error: AWS CLI no está instalado"
    exit 1
fi

# Verificar credenciales
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Error: Credenciales AWS no configuradas"
    exit 1
fi

echo ""
echo "📦 Creando Bucket S3: $BUCKET_NAME"
aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"

echo "🔒 Habilitando versionado..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

echo "🔐 Habilitando encriptación..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'

echo "🚫 Bloqueando acceso público..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo ""
echo "🗃️  Creando Tabla DynamoDB: $DYNAMODB_TABLE"
aws dynamodb create-table \
    --table-name "$DYNAMODB_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"

echo ""
echo "✅ Backend configurado exitosamente!"
echo ""
echo "📝 Actualiza tus archivos backend.tf con:"
echo "============================================"
cat <<EOF
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "foundation/iam/terraform.tfstate"  # Cambiar según componente
    region         = "$REGION"
    dynamodb_table = "$DYNAMODB_TABLE"
    encrypt        = true
  }
}
EOF
echo "============================================"
echo ""
echo "💾 Guarda estos valores:"
echo "  BUCKET_NAME: $BUCKET_NAME"
echo "  DYNAMODB_TABLE: $DYNAMODB_TABLE"
echo "  REGION: $REGION"

