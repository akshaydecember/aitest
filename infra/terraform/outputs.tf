output "app_cluster_primary" {
  value = module.ecs_primary.cluster_arn
}

output "app_cluster_secondary" {
  value = module.ecs_secondary.cluster_arn
}
