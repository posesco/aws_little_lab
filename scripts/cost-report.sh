#!/bin/bash
set -e

START_DATE=$(date -d "1 month ago" +%Y-%m-%d)
END_DATE=$(date +%Y-%m-%d)

echo "AWS Cost Report"
echo "============================================"
echo "Period: $START_DATE to $END_DATE"
echo ""

echo "Total Cost for Current Month:"
aws ce get-cost-and-usage \
    --time-period Start="$START_DATE",End="$END_DATE" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --query 'ResultsByTime[1].Total.BlendedCost.Amount' \
    --output text | xargs printf "%.5f USD\n"

echo ""
echo "Cost by Service:"
aws ce get-cost-and-usage \
    --time-period Start="$START_DATE",End="$END_DATE" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE \
    --query "ResultsByTime[1].Groups[?Metrics.BlendedCost.Amount > '0.01'].[Keys[0], Metrics.BlendedCost.Amount]" \
    --output text | awk '{cost=$NF; $NF=""; printf "%-45s %8.5f USD\n", $0, cost}'

echo ""
echo "Cost by Region:"
aws ce get-cost-and-usage \
    --time-period Start="$START_DATE",End="$END_DATE" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=REGION \
    --query "ResultsByTime[1].Groups[?Metrics.BlendedCost.Amount > '0.01'].[Keys[0], Metrics.BlendedCost.Amount]" \
    --output text | awk '{printf "  %-30s %.5f USD\n", $1, $2}'

echo ""
echo "Forecast for End of Month:"
aws ce get-cost-forecast \
    --time-period Start="$(date +%Y-%m-%d)",End="$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%Y-%m-%d)" \
    --metric BLENDED_COST \
    --granularity MONTHLY \
    --query 'Total.Amount' \
    --output text | xargs printf "%.5f USD\n"