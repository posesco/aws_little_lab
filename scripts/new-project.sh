# ============================================
# scripts/new-project.sh
# ============================================
#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "❌ Error: Debes proporcionar un nombre de proyecto"
    echo "Uso: ./new-project.sh nombre-del-proyecto"
    exit 1
fi

PROJECT_NAME=$1
PROJECT_DIR="projects/$PROJECT_NAME"
TEMPLATE_DIR="projects/_template"

# Verificar que estamos en la raíz del proyecto
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "❌ Error: Ejecuta este script desde la raíz del repositorio"
    exit 1
fi

# Verificar que el proyecto no existe
if [ -d "$PROJECT_DIR" ]; then
    echo "❌ Error: El proyecto '$PROJECT_NAME' ya existe"
    exit 1
fi

echo "🚀 Creando nuevo proyecto: $PROJECT_NAME"
echo "============================================"

# Copiar template
cp -r "$TEMPLATE_DIR" "$PROJECT_DIR"

# Actualizar backend.tf con el nombre del proyecto
if [ "$(uname)" == "Darwin" ]; then
    # macOS
    sed -i '' "s/PROJECTNAME/$PROJECT_NAME/g" "$PROJECT_DIR/backend.tf"
else
    # Linux
    sed -i "s/PROJECTNAME/$PROJECT_NAME/g" "$PROJECT_DIR/backend.tf"
fi

# Crear archivo terraform.tfvars desde example
cp "$PROJECT_DIR/terraform.tfvars.example" "$PROJECT_DIR/terraform.tfvars"

echo ""
echo "✅ Proyecto '$PROJECT_NAME' creado exitosamente!"
echo ""
echo "📝 Próximos pasos:"
echo "============================================"
echo "1. cd $PROJECT_DIR"
echo "2. vim terraform.tfvars  # Configura tus variables"
echo "3. terraform init"
echo "4. terraform plan"
echo "5. terraform apply"
echo ""
echo "📂 Archivos creados:"
ls -la "$PROJECT_DIR"

