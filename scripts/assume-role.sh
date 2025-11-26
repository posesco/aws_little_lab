#!/bin/bash
set -e

ROLE_NAME=${1:-developer}
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}-role"
SESSION_NAME="${USER}-$(date +%s)"

echo "🔐 Asumiendo Role: $ROLE_NAME"
echo "============================================"

# Solicitar MFA token
echo -n "🔢 Ingresa tu código MFA de 6 dígitos: "
read -r MFA_TOKEN

# Obtener ARN del dispositivo MFA
MFA_DEVICE=$(aws iam list-mfa-devices --query 'MFADevices[0].SerialNumber' --output text)

if [ "$MFA_DEVICE" == "None" ] || [ -z "$MFA_DEVICE" ]; then
    echo "❌ Error: No se encontró dispositivo MFA configurado"
    echo "Ejecuta: ./configure-mfa.sh <username>"
    exit 1
fi

echo "📱 Dispositivo MFA: $MFA_DEVICE"
echo "⏳ Solicitando credenciales temporales..."

# Asumir role con MFA
CREDENTIALS=$(aws sts assume-role \
    --role-arn "$ROLE_ARN" \
    --role-session-name "$SESSION_NAME" \
    --serial-number "$MFA_DEVICE" \
    --token-code "$MFA_TOKEN" \
    --duration-seconds 43200 \
    --output json)

# Extraer credenciales
export AWS_ACCESS_KEY_ID=$(echo "$CREDENTIALS" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDENTIALS" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$CREDENTIALS" | jq -r '.Credentials.SessionToken')

# Crear script para exportar variables
cat > "/tmp/assume-role-${ROLE_NAME}.sh" <<EOF
#!/bin/bash
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"
echo "✅ Credenciales temporales cargadas para role: $ROLE_NAME"
echo "⏰ Válidas por 12 horas"
EOF

chmod +x "/tmp/assume-role-${ROLE_NAME}.sh"

echo ""
echo "✅ Credenciales temporales obtenidas!"
echo ""
echo "📝 Para usar en esta sesión:"
echo "============================================"
echo "source /tmp/assume-role-${ROLE_NAME}.sh"
echo ""
echo "O ejecuta:"
echo "export AWS_ACCESS_KEY_ID=\"$AWS_ACCESS_KEY_ID\""
echo "export AWS_SECRET_ACCESS_KEY=\"$AWS_SECRET_ACCESS_KEY\""
echo "export AWS_SESSION_TOKEN=\"$AWS_SESSION_TOKEN\""
echo ""
echo "⏰ Las credenciales expiran en 12 horas"
echo ""
echo "🔍 Verificar identidad:"
echo "aws sts get-caller-identity"

