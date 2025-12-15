resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.private_subnets
  tags       = var.tags
}

resource "aws_elasticache_replication_group" "redis" {
  count = var.enabled ? 1 : 0
  replication_group_id          = "${var.name}-rg"
  replication_group_description = "Redis replication group for ${var.name}"
  node_type                     = var.node_type
  number_cache_clusters         = var.number_cache_clusters
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  automatic_failover_enabled   = true
  multi_az_enabled             = true
  engine                       = "redis"
  engine_version               = var.engine_version
  parameter_group_name         = var.parameter_group_name
  security_group_ids           = var.security_group_ids
  tags = var.tags
}

output "redis_primary_endpoint" {
  value = aws_elasticache_replication_group.redis[0].primary_endpoint_address
  depends_on = [aws_elasticache_replication_group.redis]
}
