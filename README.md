# AWS Lab Infrastructure

Terraform-based Infrastructure as Code (IaC) project for managing foundational AWS resources across multiple environments (dev, staging, prod).

## Architecture

```
foundation/              # Core infrastructure modules (deploy in order)
├── tfstate/            # S3 backend for Terraform state
├── networking/         # VPC, subnets, gateways, VPC endpoints
├── iam/                # Users, groups, roles, access keys
└── billing/            # Budget alerts and cost monitoring
modules/
└── common-tags/        # Shared tagging module
scripts/                # Operational utilities
```

## Prerequisites

- Terraform >= 1.10.0
- AWS Provider ~> 5.0
- AWS CLI configured with appropriate credentials

## Deployment Order

1. **tfstate** - Bootstrap remote state backend
2. **networking** - Create VPC and network infrastructure
3. **iam** - Configure identity and access management
4. **billing** - Set up cost monitoring

## Quick Start

```bash
# Initialize and deploy a module
cd foundation/<module>
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Foundation Modules

### tfstate
S3 bucket for remote Terraform state with versioning, encryption, and lifecycle policies.

### networking
- VPC (10.0.0.0/16)
- Public subnets: 10.0.1.0/24, 10.0.2.0/24
- Private subnets: 10.0.11.0/24, 10.0.12.0/24
- Internet Gateway
- S3 and DynamoDB VPC endpoints

### iam
RBAC groups with predefined permissions:
| Group | Access Level |
|-------|-------------|
| admins | AdministratorAccess |
| developers | EC2 + RDS full access |
| finance | Billing read-only |
| pipeline-deployers | PowerUser + IAM read-only |

### billing
AWS Budget alerts with configurable thresholds and email notifications.

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/assume-role.sh` | Manage Cost Explorer role assumption |
| `scripts/cost-report.sh` | Generate AWS cost reports |

## Tagging Strategy

All resources include standard tags: `ManagedBy`, `Owner`, `Environment`, `Project`, `Component`.

## License

Internal use only.
