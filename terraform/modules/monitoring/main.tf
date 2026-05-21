locals {
  name_prefix   = "${var.project_name}-${var.environment}"
  alarm_actions = var.alarm_topic_arn != "" ? [var.alarm_topic_arn] : []
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = var.backend_log_group_name
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "deployments" {
  name              = "/starttech/${var.environment}/deployments"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_dashboard" "operations" {
  dashboard_name = "${local.name_prefix}-ops"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          title   = "ALB Request Count"
          region  = var.aws_region
          view    = "timeSeries"
          metrics = [["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_full_name]]
          stat    = "Sum"
        }
      },
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          title   = "ASG Healthy Instance Count"
          region  = var.aws_region
          view    = "timeSeries"
          metrics = [["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", var.autoscaling_group]]
          stat    = "Average"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${local.name_prefix}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Backend target group is returning elevated 5xx responses."
  alarm_actions       = local.alarm_actions

  dimensions = {
    LoadBalancer = var.alb_full_name
    TargetGroup  = var.target_group_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  alarm_name          = "${local.name_prefix}-redis-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Redis CPU is above the expected steady-state threshold."
  alarm_actions       = local.alarm_actions

  dimensions = {
    ReplicationGroupId = var.redis_replication_id
  }
}
