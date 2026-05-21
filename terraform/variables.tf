variable "project_name" {
  description = "Logical project name used in resource naming."
  type        = string
  default     = "starttech"
}

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the main application VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used for the deployment."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.20.0.0/24", "10.20.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks for backend and data services."
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.11.0/24"]
}

variable "enable_single_nat_gateway" {
  description = "Use a single NAT gateway to reduce costs in non-production setups."
  type        = bool
  default     = true
}

variable "frontend_bucket_name" {
  description = "Optional fixed S3 bucket name for the frontend."
  type        = string
  default     = ""
}

variable "frontend_index_document" {
  description = "Default index document for static hosting."
  type        = string
  default     = "index.html"
}

variable "frontend_error_document" {
  description = "Error document for static hosting."
  type        = string
  default     = "index.html"
}

variable "cloudfront_price_class" {
  description = "CloudFront price class to use."
  type        = string
  default     = "PriceClass_100"
}

variable "backend_instance_type" {
  description = "EC2 instance type used by the backend Auto Scaling Group."
  type        = string
  default     = "t3.micro"
}

variable "backend_min_size" {
  description = "Minimum number of backend instances."
  type        = number
  default     = 2
}

variable "backend_max_size" {
  description = "Maximum number of backend instances."
  type        = number
  default     = 4
}

variable "backend_desired_capacity" {
  description = "Desired number of backend instances."
  type        = number
  default     = 2
}

variable "backend_app_port" {
  description = "Application port exposed by the Go API container."
  type        = number
  default     = 8080
}

variable "backend_health_check_path" {
  description = "Backend health endpoint used by the ALB."
  type        = string
  default     = "/health"
}

variable "ssh_allowed_cidr_blocks" {
  description = "CIDR blocks that may access EC2 instances over SSH."
  type        = list(string)
  default     = []
}

variable "redis_allowed_cidr_blocks" {
  description = "Additional CIDR blocks that may connect to Redis."
  type        = list(string)
  default     = []
}

variable "redis_node_type" {
  description = "ElastiCache instance class."
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_cache_clusters" {
  description = "Number of Redis cache nodes."
  type        = number
  default     = 2
}

variable "redis_engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.1"
}

variable "log_retention_days" {
  description = "Retention period for CloudWatch logs."
  type        = number
  default     = 30
}

variable "alarm_topic_arn" {
  description = "Optional SNS topic ARN for CloudWatch alarms."
  type        = string
  default     = ""
}

variable "mongodb_uri_parameter_name" {
  description = "SSM parameter name that stores the MongoDB Atlas URI."
  type        = string
  default     = "/starttech/prod/mongodb-uri"
}

variable "jwt_secret_parameter_name" {
  description = "SSM parameter name that stores the JWT signing secret."
  type        = string
  default     = "/starttech/prod/jwt-secret"
}

variable "mongodb_database_name" {
  description = "MongoDB database name consumed by the backend."
  type        = string
  default     = "muchtodo"
}
