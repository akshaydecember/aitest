locals {
  common_tags = {
    Project = "multi-region-webapp"
    Environment = var.environment
  }
}

# Create VPCs in both regions
module "vpc_primary" {
  source = "./modules/vpc"
  providers = { aws = aws.primary }
  name = "${var.environment}-primary"
  cidr_block = var.vpc_cidr
  public_subnets_cidrs = ["10.0.1.0/24","10.0.2.0/24"]
  private_subnets_cidrs = ["10.0.101.0/24","10.0.102.0/24"]
  azs = ["${var.primary_region}a","${var.primary_region}b"]
  tags = local.common_tags
}

module "vpc_secondary" {
  source = "./modules/vpc"
  providers = { aws = aws.secondary }
  name = "${var.environment}-secondary"
  cidr_block = "10.1.0.0/16"
  public_subnets_cidrs = ["10.1.1.0/24","10.1.2.0/24"]
  private_subnets_cidrs = ["10.1.101.0/24","10.1.102.0/24"]
  azs = ["${var.secondary_region}a","${var.secondary_region}b"]
  tags = local.common_tags
}

# RDS primary (multi-AZ) in primary region
module "rds_primary" {
  source = "./modules/rds"
  providers = { aws = aws.primary }
  name = "${var.environment}-rds"
  private_subnets = module.vpc_primary.private_subnets
  security_group_ids = []
  db_name = "appdb"
  username = "admin"
  password = "changeme123" # replace with secure secret in real deployment
  create_cross_region_replica = true
  replica_db_subnet_group = "${var.environment}-replica-subnet-group"
  tags = local.common_tags
}

# --- Application Load Balancers (one per region) ---
# Security groups for ALBs
resource "aws_security_group" "alb_sg_primary" {
  provider = aws.primary
  name        = "${var.environment}-alb-sg"
  description = "Allow HTTP inbound"
  vpc_id      = module.vpc_primary.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb_primary" {
  provider = aws.primary
  name               = "${var.environment}-alb-primary"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg_primary.id]
  subnets            = module.vpc_primary.public_subnets
}

resource "aws_lb_target_group" "primary_tg" {
  provider = aws.primary
  name     = "${var.environment}-tg-primary"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc_primary.vpc_id
  target_type = "ip"
  health_check {
    path = "/"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "primary_http" {
  provider = aws.primary
  load_balancer_arn = aws_lb.alb_primary.arn
  port  = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.primary_tg.arn
  }
}

# ECS Security Group (allow ALB to reach ECS tasks)
resource "aws_security_group" "ecs_sg_primary" {
  provider = aws.primary
  name        = "${var.environment}-ecs-sg"
  description = "Allow traffic from ALB to ECS tasks"
  vpc_id      = module.vpc_primary.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg_primary.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Roles for ECS tasks (execution & task role)
resource "aws_iam_role" "ecs_task_execution_role" {
  provider = aws.primary
  name = "${var.environment}-ecs-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_attach1" {
  provider = aws.primary
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_exec_attach2" {
  provider = aws.primary
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role" "ecs_task_role" {
  provider = aws.primary
  name = "${var.environment}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
}

# Secondary region ALB
resource "aws_security_group" "alb_sg_secondary" {
  provider = aws.secondary
  name        = "${var.environment}-alb-sg-secondary"
  description = "Allow HTTP inbound"
  vpc_id      = module.vpc_secondary.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb_secondary" {
  provider = aws.secondary
  name               = "${var.environment}-alb-secondary"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg_secondary.id]
  subnets            = module.vpc_secondary.public_subnets
}

resource "aws_lb_target_group" "secondary_tg" {
  provider = aws.secondary
  name     = "${var.environment}-tg-secondary"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc_secondary.vpc_id
  target_type = "ip"
  health_check {
    path = "/"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "secondary_http" {
  provider = aws.secondary
  load_balancer_arn = aws_lb.alb_secondary.arn
  port  = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.secondary_tg.arn
  }
}

# ECS Security Group (secondary)
resource "aws_security_group" "ecs_sg_secondary" {
  provider = aws.secondary
  name        = "${var.environment}-ecs-sg-secondary"
  description = "Allow traffic from ALB to ECS tasks"
  vpc_id      = module.vpc_secondary.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg_secondary.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- ECS clusters and services in both regions (pass target group ARNs) ---
module "ecs_primary" {
  source = "./modules/ecs"
  providers = { aws = aws.primary }
  name = "${var.environment}-app"
  container_image = var.app_container_image
  private_subnets = module.vpc_primary.private_subnets
  security_group_ids = [aws_security_group.ecs_sg_primary.id]
  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn = var.ecs_task_role_arn
  environment_variables = { DATABASE_ENDPOINT = module.rds_primary.primary_endpoint }
  desired_count = 2
  load_balancer_target_group_arn = aws_lb_target_group.primary_tg.arn
}

module "ecs_secondary" {
  source = "./modules/ecs"
  providers = { aws = aws.secondary }
  name = "${var.environment}-app-secondary"
  container_image = var.app_container_image
  private_subnets = module.vpc_secondary.private_subnets
  security_group_ids = [aws_security_group.ecs_sg_secondary.id]
  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn = var.ecs_task_role_arn
  environment_variables = { DATABASE_ENDPOINT = module.rds_primary.primary_endpoint }
  desired_count = 2
  load_balancer_target_group_arn = aws_lb_target_group.secondary_tg.arn
}

# Route53: find hosted zone and create failover records
data "aws_route53_zone" "primary" {
  name = var.domain_name
  private_zone = false
}

resource "aws_route53_health_check" "alb_primary_hc" {
  provider = aws.primary
  fqdn = aws_lb.alb_primary.dns_name
  port = 80
  type = "HTTP"
  resource_path = "/"
  request_interval = 30
  failure_threshold = 3
}

resource "aws_route53_health_check" "alb_secondary_hc" {
  provider = aws.secondary
  fqdn = aws_lb.alb_secondary.dns_name
  port = 80
  type = "HTTP"
  resource_path = "/"
  request_interval = 30
  failure_threshold = 3
}

resource "aws_route53_record" "app_primary" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${var.record_name}.${var.domain_name}"
  type    = "A"
  set_identifier = "primary-${var.primary_region}"
  failover = "PRIMARY"
  alias {
    name = aws_lb.alb_primary.dns_name
    zone_id = aws_lb.alb_primary.zone_id
    evaluate_target_health = true
  }
  health_check_id = aws_route53_health_check.alb_primary_hc.id
}

resource "aws_route53_record" "app_secondary" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${var.record_name}.${var.domain_name}"
  type    = "A"
  set_identifier = "secondary-${var.secondary_region}"
  failover = "SECONDARY"
  alias {
    name = aws_lb.alb_secondary.dns_name
    zone_id = aws_lb.alb_secondary.zone_id
    evaluate_target_health = true
  }
  health_check_id = aws_route53_health_check.alb_secondary_hc.id
}

# Optional ElastiCache (Redis) in primary region
module "redis_primary" {
  source = "./modules/elasticache"
  providers = { aws = aws.primary }
  name = "${var.environment}-redis"
  private_subnets = module.vpc_primary.private_subnets
  security_group_ids = []
  enabled = var.enable_redis
  tags = local.common_tags
}


output "primary_vpc_id" { value = module.vpc_primary.vpc_id }
output "secondary_vpc_id" { value = module.vpc_secondary.vpc_id }
