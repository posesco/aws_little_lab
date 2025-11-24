# ============================================
# scripts/configure-mfa.sh
# ============================================
#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "❌ Error: Debes proporcionar el nombre de usuario IAM"
    echo "Uso: ./configure-mfa.sh <username>"
    exit 1
fi

USERNAME=$1

echo "🔐 Configurando MFA para usuario: $USERNAME"
echo "============================================"

# Crear dispositivo MFA virtual
echo "📱 Creando dispositivo MFA virtual..."
MFA_OUTPUT=$(aws iam create-virtual-mfa-device \
    --virtual-mfa-device-name "${USERNAME}-mfa" \
    --outfile "/tmp/${USERNAME}-qr.png" \
    --bootstrap-method QRCodePNG)

MFA_SERIAL=$(echo "$MFA_OUTPUT" | jq -r '.VirtualMFADevice.SerialNumber')

echo ""
echo "✅ Dispositivo MFA creado: $MFA_SERIAL"
echo "📱 Código QR guardado en: /tmp/${USERNAME}-qr.png"
echo ""
echo "📝 Pasos siguientes:"
echo "============================================"
echo "1. Abre tu app de autenticación (Google Authenticator, Authy, etc.)"
echo "2. Escanea el código QR en: /tmp/${USERNAME}-qr.png"
echo "3. Ingresa dos códigos consecutivos cuando se soliciten"
echo ""

# Solicitar códigos de verificación
echo -n "🔢 Ingresa el primer código MFA (6 dígitos): "
read -r CODE1

echo -n "🔢 Ingresa el segundo código MFA (6 dígitos): "
read -r CODE2

echo ""
echo "⏳ Habilitando MFA..."

# Habilitar MFA
aws iam enable-mfa-device \
    --user-name "$USERNAME" \
    --serial-number "$MFA_SERIAL" \
    --authentication-code1 "$CODE1" \
    --authentication-code2 "$CODE2"

echo ""
echo "✅ MFA configurado exitosamente!"
echo ""
echo "📝 Información del dispositivo:"
echo "============================================"
echo "Usuario: $USERNAME"
echo "Serial: $MFA_SERIAL"
echo ""
echo "🔒 Ahora puedes asumir roles con MFA:"
echo "  ./assume-role.sh developer"

# Limpiar archivo QR
rm -f "/tmp/${USERNAME}-qr.png"

