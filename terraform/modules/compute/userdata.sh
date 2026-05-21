#!/bin/bash
set -e

# =========================================
# VARIABLES
# =========================================

REGION="us-east-1"
ACCOUNT_ID="327082974817"
REPOSITORY="prod-starttech-backend"

# =========================================
# SYSTEM UPDATE
# =========================================

dnf update -y

# =========================================
# INSTALL DOCKER
# =========================================

dnf install -y docker

systemctl enable docker
systemctl start docker

# =========================================
# INSTALL AWS CLI
# =========================================

dnf install -y aws-cli

# =========================================
# CLEAN OLD DOCKER RESOURCES
# =========================================

docker system prune -af || true

# =========================================
# FETCH PARAMETERS FROM SSM
# =========================================

MONGO_URI=$(aws ssm get-parameter \
  --name "/starttech/prod/mongo_uri" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region $REGION)

JWT_SECRET_KEY=$(aws ssm get-parameter \
  --name "/starttech/prod/jwt_secret" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region $REGION)

DB_NAME=$(aws ssm get-parameter \
  --name "/starttech/prod/db_name" \
  --query "Parameter.Value" \
  --output text \
  --region $REGION)

REDIS_HOST=$(aws ssm get-parameter \
  --name "/starttech/prod/redis_host" \
  --query "Parameter.Value" \
  --output text \
  --region $REGION)

# =========================================
# LOGIN TO AMAZON ECR
# =========================================

aws ecr get-login-password --region $REGION | \
docker login \
  --username AWS \
  --password-stdin \
  $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# =========================================
# PULL LATEST IMAGE
# =========================================

docker pull \
$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY:latest

# =========================================
# STOP OLD CONTAINER
# =========================================

docker stop backend || true
docker rm backend || true

# =========================================
# RUN BACKEND CONTAINER
# =========================================

docker run -d \
  --name backend \
  --restart always \
  -p 8080:8080 \
  -e PORT=8080 \
  -e MONGO_URI="$MONGO_URI" \
  -e DB_NAME="$DB_NAME" \
  -e JWT_SECRET_KEY="$JWT_SECRET_KEY" \
  -e ENABLE_CACHE=true \
  -e REDIS_ADDR="$REDIS_HOST:6379" \
  -e ALLOWED_ORIGINS="http://localhost:5173" \
  $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY:latest

# =========================================
# VERIFY CONTAINER
# =========================================

docker ps -a
