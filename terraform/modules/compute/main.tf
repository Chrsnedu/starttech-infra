data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "instance_access" {
  statement {
    sid = "CloudWatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ReadDeploymentParameters"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "DecryptSecureParameters"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
  }

  statement {
    sid = "PullImagesFromECR"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }
}

locals {
  name_prefix             = "${var.project_name}-${var.environment}"
  backend_image_parameter = "/${var.project_name}/${var.environment}/backend-image"
}

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Allow public HTTP access to the application load balancer."
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Allow ALB traffic into backend instances."
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  dynamic "ingress" {
    for_each = length(var.ssh_allowed_cidr_blocks) > 0 ? [1] : []

    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "${local.name_prefix}-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ssm_parameter" "backend_image" {
  name  = local.backend_image_parameter
  type  = "String"
  value = "${aws_ecr_repository.backend.repository_url}:initial"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${local.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_policy" "instance_access" {
  name   = "${local.name_prefix}-instance-access"
  policy = data.aws_iam_policy_document.instance_access.json
}

resource "aws_iam_role_policy_attachment" "instance_access" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.instance_access.arn
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_lb" "this" {
  name               = substr("${local.name_prefix}-alb", 0, 32)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "api" {
  name        = substr("${local.name_prefix}-tg", 0, 32)
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    path                = var.health_check_path
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_launch_template" "api" {
  name_prefix   = "${local.name_prefix}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2.arn
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app.id]
  }

  user_data = base64encode(templatefile("${path.module}/user-data.sh.tftpl", {
    aws_region              = var.aws_region
    app_port                = var.app_port
    backend_image_parameter = local.backend_image_parameter
    cloudwatch_log_group    = var.cloudwatch_log_group_name
    mongodb_uri_parameter   = var.mongodb_uri_parameter_name
    jwt_secret_parameter    = var.jwt_secret_parameter_name
    mongodb_database_name   = var.mongodb_database_name
    redis_host              = var.redis_host
    redis_port              = var.redis_port
    frontend_origin_domain  = var.frontend_origin_domain
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name_prefix}-backend"
    }
  }
}

resource "aws_autoscaling_group" "api" {
  name                      = "${local.name_prefix}-asg"
  vpc_zone_identifier       = var.private_subnet_ids
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  health_check_type         = "ELB"
  health_check_grace_period = 180
  target_group_arns         = [aws_lb_target_group.api.arn]

  launch_template {
    id      = aws_launch_template.api.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 120
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-backend"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "${local.name_prefix}-cpu-scale"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.api.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60
  }
}
