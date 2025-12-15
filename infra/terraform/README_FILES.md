/*
This file documents the purpose of key files in infra/terraform

- `providers.tf` : Defines two AWS providers (primary & secondary regions).
- `variables.tf` : Shared variables used across the root module and modules.
- `backend.tf` : Example backend configuration (commented) for S3 remote state.
- `modules/` : Terraform modules: `vpc`, `ecs`, `rds`.
- `main.tf` : Root orchestration calling modules in both regions.
- `envs/*.tfvars` : Environment-specific variable files (dev/stage/prod).

*/
