variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cloudfront_price_class" {
  type = string
}

variable "frontend_bucket_name" {
  type = string
}

variable "frontend_index_document" {
  type = string
}

variable "frontend_error_document" {
  type = string
}

variable "redis_node_type" {
  type = string
}

variable "redis_num_cache_clusters" {
  type = number
}

variable "redis_engine_version" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "redis_allowed_cidr_blocks" {
  type = list(string)
}
