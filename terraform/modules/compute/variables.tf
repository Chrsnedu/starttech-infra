variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "app_port" {
  type = number
}

variable "health_check_path" {
  type = string
}

variable "ssh_allowed_cidr_blocks" {
  type = list(string)
}

variable "cloudwatch_log_group_name" {
  type = string
}

variable "mongodb_uri_parameter_name" {
  type = string
}

variable "jwt_secret_parameter_name" {
  type = string
}

variable "mongodb_database_name" {
  type = string
}

variable "redis_host" {
  type = string
}

variable "redis_port" {
  type = number
}

variable "frontend_origin_domain" {
  type = string
}
