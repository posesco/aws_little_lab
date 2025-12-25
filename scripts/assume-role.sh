#!/bin/bash
# Usage: ./assume-role.sh [assume|unassume|check]

set -e

CREDENTIALS_FILE="/tmp/aws-assumed-role-$$"
EXPIRATION_FILE="/tmp/aws-role-expiration-$$"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID}"

assume_role() {
    echo "Assuming Cost Explorer role..."
    
    local creds=$(aws sts assume-role \
        --role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/cost-explorer-reader \
        --role-session-name cost-explorer-$$-$(date +%s) \
        --duration-seconds 3600 \
        --output json)
    
    if [ $? -ne 0 ]; then
        echo "Error assuming role"
        exit 1
    fi
    
    export AWS_ACCESS_KEY_ID=$(echo $creds | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $creds | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $creds | jq -r .Credentials.SessionToken)
    local expiration=$(echo $creds | jq -r .Credentials.Expiration)
    
    echo "export AWS_ACCESS_KEY_ID='$AWS_ACCESS_KEY_ID'" > "$CREDENTIALS_FILE"
    echo "export AWS_SECRET_ACCESS_KEY='$AWS_SECRET_ACCESS_KEY'" >> "$CREDENTIALS_FILE"
    echo "export AWS_SESSION_TOKEN='$AWS_SESSION_TOKEN'" >> "$CREDENTIALS_FILE"
    echo "$expiration" > "$EXPIRATION_FILE"
    
    echo ""
    echo "✓ Cost Explorer role assumed successfully"
    echo "==========================================="
    echo "Expiration: $expiration"
    echo "==========================================="
    echo ""
    echo "To use these credentials in this session:"
    echo "  source $CREDENTIALS_FILE"
    echo ""
    echo "To check remaining time:"
    echo "  $0 check"
    echo ""
    echo "To clear credentials:"
    echo "  $0 unassume"
    echo ""
}

unassume_role() {
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
    
    rm -f "$CREDENTIALS_FILE" "$EXPIRATION_FILE" 2>/dev/null
    
    echo "✓ Role credentials cleared"
}

check_expiration() {
    if [ ! -f "$EXPIRATION_FILE" ]; then
        echo "No role currently assumed"
        exit 1
    fi
    
    local expiration=$(cat "$EXPIRATION_FILE")
    local exp_epoch=$(date -d "$expiration" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$expiration" +%s 2>/dev/null)
    local now_epoch=$(date +%s)
    local remaining=$((exp_epoch - now_epoch))
    
    if [ $remaining -le 0 ]; then
        echo "⚠ Credentials have EXPIRED"
        echo "Expired at: $expiration"
        unassume_role
        exit 1
    fi
    
    local minutes=$((remaining / 60))
    local seconds=$((remaining % 60))
    
    echo "==========================================="
    echo "Assumed role status:"
    echo "==========================================="
    echo "Expires in: ${minutes}m ${seconds}s"
    echo "Expiration date: $expiration"
    echo "==========================================="
}

# Main menu
case "${1:-assume}" in
    assume)
        assume_role
        ;;
    unassume|clear)
        unassume_role
        ;;
    check|status)
        check_expiration
        ;;
    *)
        echo "Usage: $0 [assume|unassume|check]"
        echo ""
        echo "Commands:"
        echo "  assume    - Assume the role (default)"
        echo "  unassume  - Clear credentials"
        echo "  check     - Verify expiration time"
        exit 1
        ;;
esac