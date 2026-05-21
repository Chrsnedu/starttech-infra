# Infrastructure Runbook

## Common Operations

### Apply Infrastructure Changes

Run:

```bash
TF_STATE_BUCKET=... TF_LOCK_TABLE=... ./scripts/deploy-infrastructure.sh
```

### Check Backend Availability

- Confirm the ALB target group reports healthy instances.
- Review `/aws/ec2/starttech-prod/backend` in CloudWatch Logs.
- Hit the backend `/health` endpoint through the ALB DNS name.

### Investigate Redis Issues

- Check the `redis-high-cpu` alarm state.
- Confirm the Redis security group still allows the backend security group on port `6379`.
- Review recent backend logs for cache fallback messages.

### Roll Back Application Traffic

- The infrastructure itself usually does not need rollback for app-only issues.
- Use the application repo rollback script to point the ASG at the previous image tag and trigger a fresh instance refresh.

## Troubleshooting

- `terraform init` fails: verify the state bucket, lock table, and AWS role secrets are present.
- EC2 instances never become healthy: confirm the instance role can read SSM, pull from ECR, and write to CloudWatch logs.
- Frontend returns 403 through CloudFront: verify the bucket policy still trusts the distribution ARN and that the uploaded build contains `index.html`.
