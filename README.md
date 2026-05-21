# StartTech Infrastructure

This repository provisions the AWS foundation for the StartTech assessment using Terraform and deploys it through GitHub Actions. The stack includes a VPC, public and private subnets, an internet gateway, NAT, an Application Load Balancer, an Auto Scaling Group for the Go API, an ECR repository, an S3 bucket for the React build, CloudFront, ElastiCache Redis, and CloudWatch logs and alarms.

## Layout

- `terraform/`: root Terraform configuration and reusable modules.
- `scripts/deploy-infrastructure.sh`: local helper that mirrors the CI pipeline.
- `monitoring/`: dashboard, alarm, and Logs Insights reference assets.

## Required GitHub Secrets And Variables

- `AWS_GITHUB_ROLE_ARN`: IAM role assumed by GitHub Actions via OIDC.
- `TF_STATE_BUCKET`: S3 bucket that stores Terraform state.
- `TF_LOCK_TABLE`: DynamoDB table for state locking.
- `vars.AWS_REGION`: optional region override.
- `vars.TF_STATE_KEY`: optional Terraform state key.

## Manual Setup

1. Create the remote Terraform state bucket and lock table.
2. Create an IAM role for GitHub OIDC and allow it to manage the resources in this stack.
3. Store the MongoDB Atlas connection string in SSM Parameter Store at the name defined by `mongodb_uri_parameter_name`.
4. Run `scripts/deploy-infrastructure.sh` locally or push to `main` to let GitHub Actions apply the stack.

## Deployment Flow

1. Pull requests run `terraform fmt`, `tfsec`, `validate`, and `plan`.
2. Pushes to `main` run the same checks and then apply the saved plan.
3. The application repository uses the resulting bucket, CloudFront distribution, ECR repository, and Auto Scaling Group for deployments.
