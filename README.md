# StartTech Infrastructure

This repository provisions the production AWS infrastructure for the StartTech application.

The intended target account is:

- AWS account: `327082974817`
- region: `us-east-1`

## Repository Layout

- `terraform/`: root configuration and reusable modules
- `scripts/`: local helper scripts
- `monitoring/`: dashboards, alarms, and log query references
- `.github/workflows/`: infrastructure CI/CD

## What This Stack Creates

- VPC with public and private subnets
- Internet gateway and NAT gateway
- Internet-facing Application Load Balancer
- EC2 Auto Scaling Group for the backend
- ECR repository for backend images
- S3 website bucket for frontend hosting
- ElastiCache Redis
- CloudWatch log group and monitoring resources

## Key Terraform Outputs

- `alb_dns_name`
- `frontend_bucket_name`
- `frontend_website_url`
- `ecr_repository_url`
- `redis_endpoint`
- `backend_log_group_name`

## Required SSM Parameters

The compute layer expects these production parameters:

- `/starttech/prod/mongo_uri`
- `/starttech/prod/jwt_secret`
- `/starttech/prod/db_name`
- `/starttech/prod/redis_host`

## Remote State

Terraform state is stored remotely in S3 with DynamoDB locking.

## Usage

Before running Terraform locally, make sure the active AWS identity is the production account:

```bash
export AWS_PROFILE="krist"
aws sts get-caller-identity
```

The returned account should be `327082974817`.

Then run:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```
