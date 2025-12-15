# Multi-Region Highly-Available Web App Template (AWS)

This repository contains a starter template to deploy a highly available, multi-region web application on AWS using Terraform, ECS (Fargate), RDS (Aurora/RDS) and Route53 failover routing. It also includes a minimal Node.js app and GitHub Actions CI/CD workflows for `dev`, `stage`, and `prod` branches.

IMPORTANT: This is a template. You must configure AWS credentials, S3 remote state (recommended), and fill provider/account-specific values before applying.

Security note: Do NOT commit AWS access keys or secrets into the repository. Use one of the following secure options:

- Set environment variables locally (examples below).
- Use AWS named profiles in `~/.aws/credentials` and reference them with `aws_profile` in TF vars.
- Store secrets in an external secret manager (AWS Secrets Manager) and fetch them in CI via secure provider integrations.
- For GitHub Actions, set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as repository secrets and reference them in workflows.

Example (PowerShell):

```powershell
$env:AWS_ACCESS_KEY_ID = "<YOUR_AWS_ACCESS_KEY_ID>"
$env:AWS_SECRET_ACCESS_KEY = "<YOUR_AWS_SECRET_ACCESS_KEY>"
$env:AWS_DEFAULT_REGION = "us-west-1"
```

Example (bash):

```bash
export AWS_ACCESS_KEY_ID="<YOUR_AWS_ACCESS_KEY_ID>"
export AWS_SECRET_ACCESS_KEY="<YOUR_AWS_SECRET_ACCESS_KEY>"
export AWS_DEFAULT_REGION="us-west-1"
```

In CI (GitHub Actions), add repository secrets `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` and reference them in the workflow environment or via `aws-actions/configure-aws-credentials` action.


Quick contents
- `infra/terraform/` - Terraform code (providers, modules, envs)
- `app/` - Minimal Node.js web app + Dockerfile + ECS task template
- `.github/workflows/` - GitHub Actions for CI/CD
- `scripts/` - Helper scripts to initialize git branches and bootstrap environment
- `TEST_PLAN.md` - Steps to validate failover and scaling

Read `infra/terraform/README.md` for Terraform-specific deploy steps.
