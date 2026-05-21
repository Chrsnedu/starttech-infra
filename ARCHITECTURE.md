# Infrastructure Architecture

## Network Topology

- One VPC: `vpc-07f532a2018da2955`
- Two public subnets for the ALB and NAT path
- Two private subnets for backend instances and Redis

The ALB is public. Backend instances and Redis are private.

## Compute Path

- EC2 instances are launched through an Auto Scaling Group
- Instances boot with user-data from `terraform/modules/compute/userdata.sh`
- The backend container listens on port `8080`
- The ALB target group forwards HTTP traffic to `:8080`

## Health Model

- ALB liveness check: `/ping`
- application dependency check: `/health`

This separation is important:

- `/ping` should stay simple so the ALB can keep healthy targets in service
- `/health` is used to understand dependency status such as MongoDB and Redis

## Data And Supporting Services

- MongoDB Atlas is external to AWS and reached from the backend over the internet
- Redis runs in ElastiCache inside the private subnets
- Frontend assets are served from the S3 website bucket
- Backend logs go to CloudWatch

## Security Model

- GitHub Actions should assume a role in account `327082974817`
- EC2 instances use an instance profile with ECR, SSM, and CloudWatch permissions
- Security groups restrict:
  - ALB ingress from the internet
  - backend ingress from the ALB on `8080`
  - Redis ingress from the backend on `6379`

## Operational Risk To Watch

The most fragile dependency in this stack is MongoDB Atlas connectivity. If the backend cannot connect to Atlas during startup, the process exits and the ALB serves `502` because no targets remain healthy.
