## 03-COST-OPTIMIZATION.md - Optimización de Costos

### Servicios Más Costosos

#### 1. NAT Gateway (~32 EUR/mes por AZ)

**Problema**: Permite salida a Internet desde subnets privadas.

**Solución**: Usa VPC Endpoints (GRATIS) para S3 y DynamoDB.

```hcl
# Ya incluido en foundation/networking
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.eu-west-1.s3"
}
```

**Alternativa**: NAT Instance (t4g.nano ~3 EUR/mes) si realmente necesitas NAT.

#### 2. RDS/Aurora

**Problema**: Instancias siempre encendidas consumen todo el mes.

**Solución 1**: Aurora Serverless v2 con auto-pause
```hcl
resource "aws_rds_cluster" "this" {
  engine_mode = "provisioned"
  engine      = "aurora-postgresql"

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 1.0
  }
}
```

**Solución 2**: Usar RDS con auto-stop/start
```bash
# Script para detener RDS al terminar el día
aws rds stop-db-instance --db-instance-identifier mi-db
```

#### 3. EC2 Instances

**Problema**: Instancias corriendo 24/7.

**Solución 1**: Usar t3.micro (Free Tier 750h/mes el primer año)

**Solución 2**: Detener instancias cuando no las uses
```bash
# Script de auto-stop nocturno
aws ec2 stop-instances --instance-ids i-1234567890abcdef0
```

**Solución 3**: Spot Instances (hasta 90% descuento)
```hcl
resource "aws_instance" "this" {
  instance_market_options {
    market_type = "spot"
  }
}
```

#### 4. EBS Snapshots

**Problema**: Snapshots antiguos acumulan costo.

**Solución**: Lifecycle policy para eliminar snapshots antiguos
```bash
aws ec2 describe-snapshots --owner-ids self \
  --query 'Snapshots[?StartTime<=`2024-01-01`].[SnapshotId]' \
  --output text | xargs -n 1 aws ec2 delete-snapshot --snapshot-id
```

### Estrategias de Ahorro

#### 1. Usar Free Tier

Servicios gratuitos (12 meses):
- EC2: 750h/mes de t2.micro o t3.micro
- RDS: 750h/mes de db.t2.micro, db.t3.micro o db.t4g.micro
- S3: 5GB de almacenamiento
- Lambda: 1M requests/mes, 400,000 GB-segundos

#### 2. Tags para Tracking

```hcl
tags = {
  CostCenter  = "personal-lab"
  Project     = "mi-proyecto"
  Environment = "dev"
  AutoStop    = "true"  # Para automatización
}
```

Luego filtra costos por tag:
```bash
aws ce get-cost-and-usage \
  --filter file://<(echo '{"Tags":{"Key":"Project","Values":["mi-proyecto"]}}')
```

#### 3. Budget Alerts Configuradas

Ya incluidas en `foundation/billing`:
- Alerta al 80% del límite
- Alerta al 90%
- Alerta al 100%
- Pronóstico si se va a superar

#### 4. Usar Regiones Baratas

Costos por región (ejemplo EC2 t3.micro):
- us-east-1: $0.0104/hora
- eu-west-1: $0.0114/hora (9% más caro)
- ap-southeast-1: $0.0132/hora (27% más caro)

Para laboratorio: `us-east-1` o `eu-west-1` son buenas opciones.

### Revisar Costos Regularmente

```bash
# Script incluido
cd scripts
./cost-report.sh

# O manualmente
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

### Checklist Semanal

```bash
# 1. Ver recursos activos
aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`].[InstanceId,InstanceType,Tags[?Key==`Name`].Value|[0]]' --output table

# 2. Ver RDS activos
aws rds describe-db-instances --query 'DBInstances[?DBInstanceStatus==`available`].[DBInstanceIdentifier,DBInstanceClass]' --output table

# 3. Ver snapshots antiguos
aws ec2 describe-snapshots --owner-ids self --query 'Snapshots[?StartTime<=`2024-01-01`].[SnapshotId,StartTime,VolumeSize]' --output table

# 4. Ver volúmenes no adjuntos
aws ec2 describe-volumes --filters Name=status,Values=available --query 'Volumes[].[VolumeId,Size,CreateTime]' --output table
```
