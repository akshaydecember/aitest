variable "aws_profile" {
  type    = string
  default = "default"
}

variable "primary_region" {
  type    = string
  default = "us-east-1"
}

variable "secondary_region" {
  type    = string
  default = "us-west-2"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "domain_name" {
  type = string
  description = "Primary domain managed in Route53"
}

variable "hosted_zone_id" {
  type = string
  description = "Route53 Hosted Zone ID for the domain"
  default = ""
}

variable "record_name" {
  type = string
  description = "DNS record name (e.g. app.example.com)"
  default = "app"
}

variable "app_container_image" {
  type = string
  description = "Container image for the application"
  default = ""
}

variable "ecs_execution_role_arn" {
  type = string
  description = "ARN of ECS task execution role"
  default = ""
}

variable "ecs_task_role_arn" {
  type = string
  description = "ARN of ECS task role"
  default = ""
}

variable "enable_redis" {
  type = bool
  default = false
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
