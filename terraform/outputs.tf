output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "ecr_repository_url" {
  value = module.compute.ecr_repository_url
}

output "frontend_bucket_name" {
  value = module.storage.frontend_bucket_name
}

output "frontend_distribution_domain_name" {
  value = module.storage.cloudfront_domain_name
}

output "redis_endpoint" {
  value = module.storage.redis_primary_endpoint
}

output "backend_image_parameter_name" {
  value = module.compute.backend_image_parameter_name
}

output "backend_autoscaling_group_name" {
  value = module.compute.autoscaling_group_name
}

output "backend_log_group_name" {
  value = module.monitoring.backend_log_group_name
}
