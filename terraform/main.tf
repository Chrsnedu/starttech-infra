terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  #==========REMOTE BACKEND STATE CONFIGURATION===========
  backend "s3" {
    bucket         = "starttech-terraform-state-093796422475"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region                   = var.aws_region
  profile                  = "Krist"
  shared_credentials_files = ["~/.aws/credentials"]

  default_tags {
    tags = {
      Project     = "StartTech"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "starttech-infra"
    }
  }
}

locals {
  backend_log_group_name = "/aws/ec2/${var.project_name}-${var.environment}/backend"
}

module "networking" {
  source = "./modules/networking"

  project_name           = var.project_name
  environment            = var.environment
  vpc_cidr               = var.vpc_cidr
  availability_zones     = var.availability_zones
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  enable_single_nat_gate = var.enable_single_nat_gateway
}

module "compute" {
  source = "./modules/compute"

  aws_region                 = var.aws_region
  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.networking.vpc_id
  public_subnet_ids          = module.networking.public_subnet_ids
  private_subnet_ids         = module.networking.private_subnet_ids
  instance_type              = var.backend_instance_type
  min_size                   = var.backend_min_size
  max_size                   = var.backend_max_size
  desired_capacity           = var.backend_desired_capacity
  app_port                   = var.backend_app_port
  health_check_path          = var.backend_health_check_path
  ssh_allowed_cidr_blocks    = var.ssh_allowed_cidr_blocks
  cloudwatch_log_group_name  = local.backend_log_group_name
  mongodb_uri_parameter_name = var.mongodb_uri_parameter_name
  jwt_secret_parameter_name  = var.jwt_secret_parameter_name
  mongodb_database_name      = var.mongodb_database_name
  redis_host                 = module.storage.redis_primary_endpoint
  redis_port                 = module.storage.redis_port
  frontend_origin_domain     = module.storage.cloudfront_domain_name
}

module "storage" {
  source = "./modules/storage"

  project_name              = var.project_name
  environment               = var.environment
  cloudfront_price_class    = var.cloudfront_price_class
  frontend_bucket_name      = var.frontend_bucket_name
  frontend_index_document   = var.frontend_index_document
  frontend_error_document   = var.frontend_error_document
  redis_node_type           = var.redis_node_type
  redis_num_cache_clusters  = var.redis_num_cache_clusters
  redis_engine_version      = var.redis_engine_version
  private_subnet_ids        = module.networking.private_subnet_ids
  vpc_id                    = module.networking.vpc_id
  vpc_cidr                  = var.vpc_cidr
  redis_allowed_cidr_blocks = var.redis_allowed_cidr_blocks
}

module "monitoring" {
  source = "./modules/monitoring"

  aws_region             = var.aws_region
  project_name           = var.project_name
  environment            = var.environment
  log_retention_days     = var.log_retention_days
  backend_log_group_name = local.backend_log_group_name
  alarm_topic_arn        = var.alarm_topic_arn
  alb_full_name          = module.compute.alb_full_name
  target_group_suffix    = module.compute.target_group_suffix
  autoscaling_group      = module.compute.autoscaling_group_name
  redis_replication_id   = module.storage.redis_replication_group_id
}
