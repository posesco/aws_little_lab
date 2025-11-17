# aws-lab

Laboratorio personal en AWS provisto con Terraform.

## Requisitos
- AWS CLI configurado (`aws configure`) o variables de entorno AWS_*
- Terraform >= 1.6.0
- (Opcional) S3 + DynamoDB para backend remoto

## Flujo básico
1. Ajusta `variables.tf` o crea `terraform.tfvars` (no subir a GitHub).
2. `terraform init`
3. `terraform plan -out plan.tf`
4. `terraform apply "plan.tf"`
5. Conectarse:
   `ssh -i <ruta_a_tu_private_key> ubuntu@<public_ip>`
6. Apagar manual:
   `aws ec2 stop-instances --instance-ids <id> --region <region>`
7. Destruir:
   `terraform destroy -var='allowed_ssh_cidr=MI_IP/32'`

## Notas de seguridad
- Nunca subas claves privadas ni `terraform.tfvars` al repo.
- Usa AWS SSO/IAM roles para CI y evita almacenar credenciales estáticas.