variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "backend_log_group_name" {
  type = string
}

variable "alarm_topic_arn" {
  type = string
}

variable "alb_full_name" {
  type = string
}

variable "target_group_suffix" {
  type = string
}

variable "autoscaling_group" {
  type = string
}

variable "redis_replication_id" {
  type = string
}
