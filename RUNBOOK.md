# Infrastructure Runbook

## Before You Apply

1. Set the production AWS profile:

```bash
export AWS_PROFILE="krist"
aws sts get-caller-identity
```

2. Confirm the active account is `327082974817`.

## Apply Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Verify Core Outputs

After apply, confirm:

- `alb_dns_name`
- `frontend_bucket_name`
- `frontend_website_url`
- `ecr_repository_url`
- `redis_endpoint`
- `backend_log_group_name`

## Check Backend Availability

1. Confirm the ALB exists and is active.
2. Confirm the target group health-check path is `/ping`.
3. Confirm backend targets are registered and healthy.
4. Review backend logs in `/starttech/backend`.

## If The ALB Returns `502`

Check in this order:

1. `describe-target-health` for the backend target group
2. EC2 instance state
3. SSM access to the instances
4. `docker ps -a` and backend container logs
5. local `curl http://localhost:8080/ping` on the instances

If `/ping` fails locally, the issue is inside the backend instance, not the ALB.

## If Targets Fail During Startup

Most common causes:

- wrong or stale SSM parameter values
- ECR login or image pull failure
- MongoDB Atlas connection failure
- Redis connection failure

For MongoDB-specific failures, verify:

- `/starttech/prod/mongo_uri`
- Atlas network access rules
- TLS/connectivity errors in backend logs

## State / Resource Migration Notes

If Terraform reports duplicate security groups or dependency-violation deletes, treat it as a state migration problem first. Do not immediately delete resources manually if they are still attached to the ALB, instances, or Redis.

Prefer:

- `terraform state mv`
- `terraform import`

before destructive cleanup.
