# velura-infra-terraform

This Terraform configuration deploys the Velura microservices architecture to AWS.

## What it manages
- VPC, subnets, security groups
- ECS cluster and Fargate services
- ALB with path-based routing for `/auth`, `/catalog`, `/rental`, `/admin`
- ECR repositories for service images
- RDS MySQL instance
- Secrets Manager secret with app credentials and internal service URLs

## How it matches `velura-project-AWS-`
- Backend services use the same secret names as the app's local `.env` keys.
- Internal service URLs are stored in AWS Secrets Manager and used by ECS containers.
- Frontend image is built with `FRONTEND_*` URLs baked into `frontend/index.html`.
- ALB path routing matches the frontend API paths used by the app.

## Two-phase deployment workflow

### 1) First Terraform apply
1. Copy `terraform.tfvars.example` to `terraform.tfvars`:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Optionally generate `terraform.tfvars` from the root app `.env`:
   ```bash
   ./env-to-tfvars.sh
   ```
3. Set your AWS account ID, database credentials, and app secrets.
4. Run:
   ```bash
   terraform init
   terraform apply
   ```
5. After apply, retrieve these outputs:
   - `alb_url` for the public ALB
   - `ecr_urls` for the ECR repository URIs

### 2) Build, tag, and push Docker images
1. Log in to ECR:
   ```bash
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
   ```
2. Build and push images to the repo URLs from `ecr_urls`.
3. Update `terraform.tfvars` with the actual ECR image URIs.

### 3) Second Terraform apply
1. Re-run:
   ```bash
   terraform apply
   ```
2. This will update ECS task definitions to use the pushed images.

## `.env` mapping

Local app keys in `velura-project-AWS-/.env` map to Terraform vars as follows:
- `MYSQL_USER` -> `db_username`
- `MYSQL_PASSWORD` -> `db_password`
- `MYSQL_DATABASE` -> `db_name`
- `JWT_SECRET_KEY` -> `jwt_secret_key`
- `ELASTIC_PASSWORD` -> `elastic_password`
- `KIBANA_PASSWORD` -> `kibana_password`
- `KIBANA_ENCRYPTION_KEY` -> `kibana_encryption_key`

## Notes
- `velura-project-AWS-/.env` is for local Docker Compose only.
- `velura-infra-terraform/terraform.tfvars` is for AWS deployment.
- If you want, I can add a helper script to copy values from root `.env` into Terraform vars.
