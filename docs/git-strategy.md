# Git Strategy

## Overview

This project uses **Trunk-Based Development** as the branching strategy, optimized for Infrastructure as Code (IaC) with Terraform.

## Branching Model

```
master (protected, always deployable)
  │
  ├── feature/*    ← New functionality
  ├── fix/*        ← Bug fixes
  └── hotfix/*     ← Emergency production fixes
```

### Branch Naming Conventions

| Prefix | Use Case | Example |
|--------|----------|---------|
| `feature/` | New infrastructure components | `feature/add-rds-module` |
| `fix/` | Non-urgent bug fixes | `fix/vpc-routing-table` |
| `hotfix/` | Critical production issues | `hotfix/iam-policy-permissions` |

### Branch Rules

- Keep branches short-lived (ideally < 3 days)
- One logical change per branch
- Always branch from `master`
- Delete branch after merge

## Module Types

| Type | Modules | Workspaces | Description |
|------|---------|------------|-------------|
| **GLOBAL** | `tfstate`, `iam` | No (default) | Account-wide resources. Single state for entire AWS account. |
| **PER-ENV** | `networking`, `billing`, projects | Yes (dev/staging/prod) | Environment-specific. Separate state per workspace. |

**Why GLOBAL?**
- `tfstate`: The S3 bucket storing Terraform state is shared across all environments
- `iam`: IAM users, groups, roles, and policies are AWS account-level resources

## Environments

Environments are managed via **Terraform Workspaces** (PER-ENV modules only).

**PER-ENV modules** (networking, billing, projects):
```bash
terraform workspace list           # List workspaces
terraform workspace select dev     # Switch to dev
terraform workspace select staging # Switch to staging
terraform workspace select prod    # Switch to prod
```

**GLOBAL modules** (tfstate, iam):
```bash
# No workspace commands needed - always use default workspace
terraform init && terraform plan   # Direct execution
```

### State File Location

```
s3://bucket-name/
  ├── foundation/tfstate/terraform.tfstate              # GLOBAL (default workspace)
  ├── foundation/iam/terraform.tfstate                  # GLOBAL (default workspace)
  └── env:/
      ├── dev/foundation/networking/terraform.tfstate   # PER-ENV
      ├── staging/foundation/networking/terraform.tfstate
      └── prod/foundation/networking/terraform.tfstate
```

## CI/CD Pipeline

### Workflow File

`.github/workflows/terraform.yml`

### Pipeline Triggers

| Event | Trigger | Action |
|-------|---------|--------|
| Pull Request | Changes in `foundation/**`, `projects/**`| Plan |
| Push to master | Changes in `foundation/**`, `projects/**`| Apply |
| Manual | workflow_dispatch | Plan/Apply/Destroy |

### Automatic Change Detection

The pipeline automatically detects which modules have changed:

- **GLOBAL modules** (`tfstate`, `iam`): Deploy once, no workspace selection
- **PER-ENV modules** (`networking`, `billing`): Use workspace per environment
- **projects/**: Deploy in parallel (independent, use workspaces)

**Deploy order:** tfstate → iam → networking → billing → projects

### PR Workflow

**Pull Request Opened:**
1. Detect changed modules (GLOBAL and PER-ENV separately)
2. Run `terraform plan` for each changed module
3. Save plan as artifact (5-day retention)
4. Comment PR with plan summary

### Merge to master

**Push to master:**
1. Detect changed modules (GLOBAL and PER-ENV separately)
2. Apply GLOBAL modules (tfstate → iam) - no workspace
3. Apply PER-ENV modules (networking → billing) - workspace: dev
4. Apply project modules in parallel - workspace: dev

### Promotion Flow

**GLOBAL modules** (tfstate, iam):
```
PR ──► master ──auto──► applied (account-wide, no promotion needed)
```

**PER-ENV modules** (networking, billing, projects):
```
PR ──► master ──auto──► dev
                         │
              (manual)   ▼
                     staging
                         │
              (manual)   ▼
                       prod
```

## Manual Deployment

For staging and production, use the GitHub Actions manual trigger:

**Inputs:**

| Input | Options | Description |
|-------|---------|-------------|
| environment | `staging`, `prod` | Target environment (ignored for GLOBAL modules) |
| type | `foundation`, `project` | Module type |
| module | e.g., `networking`, `ec2_n8n` | Module name |
| action | `plan`, `apply`, `destroy` | Terraform action |

> **Note:** For GLOBAL modules (`tfstate`, `iam`), the environment selection is ignored.
> These modules always operate on the default workspace (account-wide).

### Promotion Checklist

Before promoting to production:

- [ ] Changes deployed and tested in dev
- [ ] Changes deployed and tested in staging
- [ ] Run `plan` in prod to preview changes
- [ ] Review plan output carefully
- [ ] Apply during low-traffic window (if applicable)

## Hotfix Process

For critical production issues requiring immediate fix:

**Hotfix Workflow:**
1. Create `hotfix/description` branch from master
2. Implement fix
3. Test locally: `terraform plan` (prod workspace for PER-ENV, default for GLOBAL)
4. Create PR with expedited review
5. Merge to master
6. Immediately deploy to prod via manual trigger
7. Verify fix
8. Dev/staging update on next regular deploy (PER-ENV modules only)

## GitHub Configuration

### Required Secrets

| Secret | Description |
|--------|-------------|
| `AWS_ACCOUNT_ID` | 12-digit AWS account ID |

### Required Environments

| Environment | Protection Rules |
|-------------|------------------|
| `dev` | None |
| `staging` | Required reviewers (recommended) |
| `prod` | Required reviewers + deployment branches: master only |

### Required IAM Roles (AWS)

Each role must have OIDC trust policy for GitHub Actions:

```
github-actions-terraform-dev
github-actions-terraform-staging
github-actions-terraform-prod
```

## Quick Reference

```bash
# Create feature branch
git checkout master
git pull origin master
git checkout -b feature/my-feature

# Work and commit
git add .
git commit -m "Add my feature"

# Push and create PR
git push -u origin feature/my-feature
# Create PR via GitHub UI

# After merge, clean up
git checkout master
git pull origin master
git branch -d feature/my-feature

# Manual deploy to staging
# Use GitHub Actions UI: workflow_dispatch

# Local workspace commands (PER-ENV modules only)
terraform workspace list
terraform workspace select dev
terraform plan

# GLOBAL modules (tfstate, iam) - no workspace needed
cd foundation/iam
terraform init && terraform plan
```
