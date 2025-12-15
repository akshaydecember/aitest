resource "aws_ecs_cluster" "this" {
  name = "${var.name}-ecs-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name}-task"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = var.container_image
      essential = true
      portMappings = [{ containerPort = var.container_port, protocol = "tcp" }]
      environment = var.environment_variables
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets = var.private_subnets
    security_groups = var.security_group_ids
    assign_public_ip = false
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent = 200
}

# Optional load balancer attachment (pass target group ARN)
  load_balancer {
    target_group_arn = var.load_balancer_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

# Application AutoScaling target for ECS desired count
resource "aws_appautoscaling_target" "ecs_service" {
  max_capacity       = var.autoscaling_max
  min_capacity       = var.autoscaling_min
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_target" {
  name               = "${var.name}-cpu-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.autoscaling_target_cpu
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}
