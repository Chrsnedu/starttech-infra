output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnets" {
  value = module.networking.public_subnets
}

output "private_subnets" {
  value = module.networking.private_subnets
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



output "frontend_website_url" {
  value = module.storage.frontend_website_url
}

# output "cloudfront_domain_name" {
#   value = module.storage.cloudfront_domain_name
# }

output "redis_endpoint" {
  value = module.storage.redis_endpoint
}

output "backend_log_group_name" {
  value = module.monitoring.backend_log_group_name
}
