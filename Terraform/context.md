# Arturo Project — Terraform Infrastructure

## Overview

This project provisions a small but complete AWS environment using Terraform. It follows
production-ready patterns (remote state, modular design, encrypted storage, least-privilege
security groups) while staying simple enough to understand end-to-end.

---

## Architecture

```
                        ┌─────────────────────────────────────────────┐
                        │                 AWS VPC                     │
                        │           CIDR: 10.0.0.0/16                 │
                        │                                             │
                        │   ┌─────────────────────────────────────┐   │
                        │   │        Public Subnets               │   │
                        │   │  10.0.1.0/24      10.0.2.0/24       │   │
                        │   │  us-east-1a       us-east-1b        │   │
                        │   │                                     │   │
                        │   │  ┌──────────┐    ┌──────────┐       │   │
Internet ──── IGW ──────┼───┼─▶│  EC2 web │    │  EC2 app │       │   │
                        │   │  │ t3.micro │    │ t3.micro │       │   │
                        │   │  └──────────┘    └──────────┘       │   │
                        │   └──────────────────────┬──────────────┘   │
                        │                          │ SG reference     │
                        │   ┌──────────────────────▼──────────────┐   │
                        │   │        Private Subnets              │   │
                        │   │  10.0.10.0/24     10.0.11.0/24      │   │
                        │   │  us-east-1a       us-east-1b        │   │
                        │   │                                     │   │
                        │   │         ┌──────────────┐            │   │
                        │   │         │  RDS MySQL   │            │   │
                        │   │         │  db.t3.micro │            │   │
                        │   │         └──────────────┘            │   │
                        │   └──────────────────────────────────────┘  │
                        └─────────────────────────────────────────────┘

S3 Bucket "arturo-*" ─── private, versioned, AES-256 encrypted
```

---

## Resource Inventory

| Resource           | Name pattern                          | Notes                                |
|--------------------|---------------------------------------|--------------------------------------|
| VPC                | `{project}-{env}-vpc`                 | DNS hostnames enabled                |
| Internet Gateway   | `{project}-{env}-igw`                 | Attached to VPC                      |
| Public Subnets (2) | `{project}-{env}-public-1/2`          | map_public_ip_on_launch = true       |
| Private Subnets (2)| `{project}-{env}-private-1/2`         | No route to internet, used by RDS    |
| EC2 web            | `{project}-{env}-web`                 | t3.micro, gp3 20 GiB, IMDSv2        |
| EC2 app            | `{project}-{env}-app`                 | t3.micro, gp3 20 GiB, IMDSv2        |
| RDS MySQL          | `{project}-{env}-db`                  | Private subnets, encrypted, 7d backup|
| S3 bucket          | `arturo-{env}-{suffix}`               | Versioned, SSE-AES256, no public ACLs|

---

## Project Structure

```
.
├── providers.tf          # AWS provider + Terraform version constraints
├── backend.tf            # Remote state: S3 bucket + DynamoDB lock table
├── main.tf               # Root module — wires child modules together
├── variables.tf          # All input variable declarations with descriptions
├── outputs.tf            # Key values surfaced after apply
├── terraform.tfvars      # Actual values (gitignored — never commit secrets)
├── .gitignore
├── context.md            # This file
│
└── modules/
    ├── networking/       # VPC, subnets, IGW, route tables
    ├── ec2/              # Two EC2 instances + shared security group
    ├── rds/              # RDS instance, subnet group, security group
    └── s3/               # S3 bucket with versioning, encryption, lifecycle
```

---

## Remote State

State is stored remotely to enable team collaboration and prevent concurrent apply conflicts.

**Backend resources (create once before `terraform init`):**

```bash
# 1. Create the state bucket
aws s3api create-bucket \
  --bucket terraform-state-arturo-project \
  --region us-east-1

# 2. Enable versioning on the state bucket
aws s3api put-bucket-versioning \
  --bucket terraform-state-arturo-project \
  --versioning-configuration Status=Enabled

# 3. Create the DynamoDB lock table
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

`backend.tf` references these resources. The state file itself is at:
`s3://terraform-state-arturo-project/arturo-project/terraform.tfstate`

---

## Getting Started

### Prerequisites

- Terraform >= 1.5.0 (`brew install terraform`)
- AWS CLI configured (`aws configure`)
- An IAM user/role with permissions for EC2, RDS, S3, VPC

### First-time setup

```bash
# 1. Bootstrap the remote state resources (see above)

# 2. Copy and fill in your variables
cp terraform.tfvars terraform.tfvars.local
# Edit terraform.tfvars — update rds_password and s3_bucket_name

# 3. Initialize Terraform (downloads provider, connects to backend)
terraform init

# 4. Review the execution plan
terraform plan

# 5. Apply
terraform apply
```

### Useful commands

```bash
terraform fmt -recursive          # Format all .tf files
terraform validate                # Syntax + type check
terraform plan -out=tfplan        # Save plan to file
terraform apply tfplan            # Apply saved plan
terraform output                  # Show outputs after apply
terraform destroy                 # Tear down all resources
```

---

## Security Decisions

| Decision | Reason |
|---|---|
| IMDSv2 enforced on EC2 | Prevents SSRF-based credential theft via instance metadata |
| RDS in private subnets | Database is unreachable from the internet |
| RDS security group scoped to EC2 SG | Only app/web instances can open a DB connection |
| S3 public access blocked | Objects are only reachable via IAM policies or pre-signed URLs |
| S3 + EBS volumes encrypted at rest | Satisfies compliance baselines (SOC2, PCI-DSS) |
| `sensitive = true` on RDS credentials | Prevents passwords appearing in `terraform output` or plan diffs |
| `skip_final_snapshot = true` (dev only) | Set to `false` in prod to preserve a snapshot before destroy |

---

## Environment Promotion

The `environment` variable drives naming and minor config differences. To deploy to production:

```bash
terraform workspace new prod       # optional: use workspaces
terraform apply -var="environment=prod" \
               -var="multi_az=true" \
               -var="deletion_protection=true" \
               -var="skip_final_snapshot=false"
```

For real multi-environment setups, consider separate state keys or Terragrunt.

---

## Cost Estimate (dev defaults, us-east-1)

| Resource | Approx. monthly cost |
|---|---|
| 2× EC2 t3.micro | ~$17 |
| RDS db.t3.micro (MySQL) | ~$15 |
| S3 (first 50 GB) | ~$1 |
| **Total** | **~$33/month** |

Stop/start EC2 instances when not in use to reduce costs in dev.

---

## Known Limitations & Next Steps

- **No NAT Gateway** — private subnets cannot reach the internet (add one if the app tier needs outbound access, e.g. to pull packages).
- **No ALB** — add an Application Load Balancer in front of the EC2 instances for production traffic.
- **RDS password in tfvars** — migrate to `aws_secretsmanager_secret` + `data.aws_secretsmanager_secret_version` for production.
- **Single region** — no cross-region replication on S3 or RDS read replicas.
- **No WAF or CloudFront** — add these for a production-facing web workload.
