output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_full_name" {
  value = aws_lb.this.arn_suffix
}

output "target_group_suffix" {
  value = aws_lb_target_group.api.arn_suffix
}

output "ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.api.name
}

output "backend_image_parameter_name" {
  value = aws_ssm_parameter.backend_image.name
}
