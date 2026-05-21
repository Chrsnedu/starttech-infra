# Infrastructure Architecture

## Core Design

- The frontend is built in GitHub Actions and uploaded to S3.
- CloudFront sits in front of the S3 bucket for HTTPS delivery and edge caching.
- The backend runs as a Docker container on EC2 instances launched by an Auto Scaling Group in private subnets.
- An internet-facing ALB routes traffic to the backend target group and uses `/health` for instance health checks.
- Redis runs in ElastiCache inside private subnets and is only reachable from the backend security group.
- MongoDB data lives in MongoDB Atlas, and the backend reads the Atlas URI from SSM Parameter Store during instance bootstrap.
- CloudWatch centralizes container logs and provides dashboards and alarms.

## Security Model

- GitHub Actions authenticates to AWS with OIDC instead of long-lived keys.
- Backend instances use an IAM role with the minimum permissions needed for CloudWatch logs, SSM reads, and ECR image pulls.
- Only the ALB is public.
- Backend instances and Redis remain in private subnets.
- The backend Docker container runs as a non-root user.

## Deployment Model

- Terraform owns the long-lived AWS resources.
- The backend CI pipeline pushes a new image to ECR, updates the image SSM parameter, and triggers an ASG instance refresh for a rolling deployment.
- The frontend CI pipeline uploads the static build to S3 and invalidates CloudFront so users see the latest bundle quickly.
