# Terraform Multi-Region README

This folder contains a generic Terraform template for deploying infrastructure across two AWS regions (primary and secondary).

Before you begin:

- Install Terraform >= 1.3
- Configure AWS CLI credentials (profile or env vars) with appropriate permissions
- Configure an S3 bucket + DynamoDB table for remote state (recommended). See `backend.tf` for an example.

High-level steps:

1. Edit `terraform.tfvars` files in `infra/terraform/envs/{dev,stage,prod}` to set account/region names and domain.
2. Initialize Terraform:

```bash
cd infra/terraform
terraform init
```

3. Plan and apply per environment (example for dev):

```bash
terraform workspace new dev || terraform workspace select dev
terraform plan -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars
```

Notes:
- The template uses provider aliases for multiple regions; module resources accept a `provider` argument for cross-region deployment.
- Several resources are placeholders and include comment markers where account-specific IDs or ARNs must be provided.
