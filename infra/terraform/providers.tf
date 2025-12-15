terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  alias  = "primary"
  region = var.primary_region
  profile = var.aws_profile
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
  profile = var.aws_profile
}
