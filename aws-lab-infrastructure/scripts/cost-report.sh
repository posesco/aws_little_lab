# ============================================
# scripts/cost-report.sh
# ============================================
#!/bin/bash
set -e

REGION="eu-west-1"
START_DATE=$(date -d "1 month ago" +%Y-%m-%d)
END_DATE=$(date +%Y-%m-%d)

echo "💰 Reporte de Costos AWS"
echo "============================================"
echo "📅 Período: $START_DATE a $END_DATE"
echo ""

# Costo total del mes actual
echo "📊 Costo Total del Mes Actual:"
aws ce get-cost-and-usage \
    --time-period Start="$START_DATE",End="$END_DATE" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
    --output text | xargs printf "%.2f EUR\n"

echo ""
echo "📊 Costo por Servicio:"
aws ce get-cost-and-usage \
    --time-period Start="$START_DATE",End="$END_DATE" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE \
    --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount > `0.01`].[Keys[0], Metrics.BlendedCost.Amount]' \
    --output text | awk '{printf "  %-30s %.2f EUR\n", $1, $2}'

echo ""
echo "📊 Costo por Proyecto (Tags):"
aws ce get-cost-and-usage \
    --time-period Start="$START_DATE",End="$END_DATE" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=TAG,Key=Project \
    --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount > `0.01`].[Keys[0], Metrics.BlendedCost.Amount]' \
    --output text | awk '{printf "  %-30s %.2f EUR\n", $1, $2}'

echo ""
echo "⚠️  Top 5 Recursos Más Costosos:"
aws ce get-cost-and-usage \
    --time-period Start="$START_DATE",End="$END_DATE" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=RESOURCE_ID \
    --query 'ResultsByTime[0].Groups | sort_by(@, &Metrics.BlendedCost.Amount) | reverse(@)[0:5].[Keys[0], Metrics.BlendedCost.Amount]' \
    --output text | awk '{printf "  %-50s %.2f EUR\n", $1, $2}'

echo ""
echo "📈 Pronóstico para Fin de Mes:"
aws ce get-cost-forecast \
    --time-period Start="$(date +%Y-%m-%d)",End="$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%Y-%m-%d)" \
    --metric BLENDED_COST \
    --granularity MONTHLY \
    --query 'Total.Amount' \
    --output text | xargs printf "%.2f EUR\n"

echo ""
echo "============================================"
echo "💡 Tip: Si excedes 15 EUR/mes, revisa:"
echo "  - Instancias EC2 en ejecución"
echo "  - NAT Gateways innecesarios"
echo "  - RDS sin auto-pause"
echo "  - Snapshots antiguos"