# Terraform – Lab Implementation

This directory contains the Terraform configuration adopted from the deployed hands-on AWS lab.

The public portfolio architecture in the repository root shows the production/reference target (multiple steady-state EC2 instances, RDS Multi-AZ, and NAT Gateway per AZ). This Terraform code intentionally reflects the **cost-optimized lab implementation that was actually deployed and validated**:

- EC2 Auto Scaling: Min 1 / Desired 1 / Max 2
- RDS PostgreSQL: Single-AZ
- No NAT Gateway
- Private access to S3, Secrets Manager, SSM, and SSM Messages through VPC endpoints

## Before use

Copy the example variables file and set your own alert email:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

The configuration also references the project domain and a CloudFront-managed WAF ACL used by the original lab. If reproducing the environment in another account, adjust those account/environment-specific names as appropriate.

## Workflow used in the lab

```powershell
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform plan
```

The final deployed lab returned:

```text
No changes. Your infrastructure matches the configuration.
```

## Security note

Terraform state, saved plans, generated deployment packages, and local variable files are intentionally not committed. Terraform state can contain sensitive values even when they do not appear directly in the `.tf` source.
