/*
  Remote state backend is highly recommended for multi-region deployments.
  Example S3/DynamoDB backend configuration (uncomment and fill values):

terraform {
  backend "s3" {
    bucket         = "<your-terraform-state-bucket>"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "<your-lock-table>"
    encrypt        = true
  }
}

*/

# Using local backend by default for the template. Configure remote backend before production.
