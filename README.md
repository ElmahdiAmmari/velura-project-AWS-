# 🧥 Velura — Cloud-Native Clothes Rental Platform

> A production-grade microservices application deployed on AWS, built with Python/Flask, Docker, and Terraform.

---

## 📌 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Services](#services)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Local Development](#local-development)
- [AWS Infrastructure (Terraform)](#aws-infrastructure-terraform)
- [CI/CD Pipeline](#cicd-pipeline)
- [Observability — ELK Stack](#observability--elk-stack)
- [Security](#security)
- [Environment Variables](#environment-variables)

---

## Overview

**Velura** is a full-stack clothes rental platform built with a microservices architecture. Users can browse a catalog of available clothing items, rent and return them, and manage their accounts. Administrators can add, update, and remove items from the catalog through a dedicated admin service.

The application is designed for cloud-native deployment on **AWS ECS Fargate**, with infrastructure fully managed as code via **Terraform**, and an automated **CI/CD pipeline** on GitHub Actions that handles linting, security scanning, Docker image building, ECR delivery, and rolling ECS deployments.

---

## Architecture

```
                        ┌─────────────────────────────────────┐
                        │          AWS Application             │
  Browser ──────────►  │  Load Balancer (ALB)  :80            │
                        │  Path-based routing                  │
                        └──────────┬──────────────────────────┘
                                   │
           ┌───────────────────────┼───────────────────────────┐
           │                       │                           │
           ▼                       ▼                           ▼
     ┌──────────┐          ┌──────────────┐           ┌──────────────┐
     │ Frontend │          │  Auth Svc    │           │ Catalog Svc  │
     │ (Nginx)  │          │  :5001 /auth │           │ :5002/catalog│
     └──────────┘          └──────────────┘           └──────────────┘
                                   │
                      ┌────────────┴────────────┐
                      ▼                         ▼
              ┌──────────────┐         ┌──────────────┐
              │ Rental Svc   │         │  Admin Svc   │
              │ :5003/rental │         │ :5004/admin  │
              └──────────────┘         └──────────────┘
                      │
                      ▼
           ┌───────────────────┐
           │  AWS RDS MySQL    │  (private subnet)
           └───────────────────┘

  Logging: Filebeat ──► Elasticsearch ──► Kibana
  Secrets: All sensitive config via AWS Secrets Manager
  Images:  AWS ECR (Elastic Container Registry)
  Network: VPC with public/private subnets + NAT Gateway
```

---

## Services

| Service | Port | Description |
|---|---|---|
| **Frontend** | 80 | Single-page HTML/JS app served by Nginx |
| **Auth Service** | 5001 | User registration, login, JWT token issuance & verification |
| **Catalog Service** | 5002 | Browse available clothing items (requires JWT) |
| **Rental Service** | 5003 | Rent and return items, view rental history (requires JWT) |
| **Admin Service** | 5004 | Add, update, delete catalog items (requires admin JWT) |
| **Elasticsearch** | 9200 | Log storage and search backend |
| **Kibana** | 5601 | Log visualization dashboard |
| **Filebeat** | — | Log shipper: reads Docker container logs → Elasticsearch |

### Auth Service (`/auth`)
- `POST /auth/register` — Register a new user
- `POST /auth/login` — Authenticate and receive a JWT token
- `GET /auth/verify` — Validate a token (called internally by other services)
- `GET /auth/health` — Health check endpoint

### Catalog Service (`/catalog`)
- `GET /catalog/clothes` — List all available clothing items
- `GET /catalog/health` — Health check

### Rental Service (`/rental`)
- `POST /rental/rent` — Rent an item
- `POST /rental/return` — Return a rented item
- `GET /rental/my-rentals` — View current user's rental history
- `GET /rental/health` — Health check

### Admin Service (`/admin`)
- `POST /admin/clothes` — Add a new clothing item (admin only)
- `PUT /admin/clothes/<id>` — Update an item (admin only)
- `DELETE /admin/clothes/<id>` — Delete an item (admin only)
- `GET /admin/health` — Health check

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Backend** | Python 3.11, Flask, Flask-CORS |
| **Auth** | JWT (PyJWT), bcrypt |
| **Database** | MySQL 8.0 (local: Docker container / prod: AWS RDS) |
| **Frontend** | Vanilla HTML/CSS/JS, Nginx |
| **Containerization** | Docker, Docker Compose |
| **Cloud** | AWS ECS Fargate, ECR, RDS, ALB, Secrets Manager, CloudWatch |
| **IaC** | Terraform |
| **CI/CD** | GitHub Actions |
| **Observability** | Elasticsearch 8.12, Kibana 8.12, Filebeat 8.12 |
| **Security Scanning** | Trivy (container vulnerability scanning) |
| **Code Quality** | Flake8 |

---

## Project Structure

```
velura-project-AWS-/
├── .env.example                    # Environment variable template
├── .github/
│   └── workflows/
│       └── ci.yml                  # Full CI/CD pipeline
├── frontend/
│   ├── index.html                  # Single-page app
│   ├── nginx.conf                  # Nginx config
│   └── Dockerfile
├── services/
│   ├── auth/
│   │   ├── auth_service.py
│   │   ├── requirements.txt
│   │   ├── Dockerfile
│   │   └── tests/
│   │       └── test_security.py
│   ├── catalog/
│   │   ├── catalog_service.py
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   ├── rental/
│   │   ├── rental_service.py
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   └── admin/
│       ├── admin_service.py
│       ├── requirements.txt
│       └── Dockerfile
├── shared/
│   ├── __init__.py
│   └── db.py                       # Shared MySQL connection helper
└── infra/
    ├── docker/
    │   ├── docker-compose.yml          # Local dev stack (full)
    │   ├── docker-compose-prod.yml     # Production stack (no local MySQL)
    │   ├── nginx.conf                  # API gateway config
    │   ├── init.sql                    # DB schema initialization
    │   ├── filebeat.yml                # Filebeat config
    │   └── filebeat-image/
    │       ├── Dockerfile
    │       └── filebeat.yml
    ├── scripts/
    │   ├── generate-secrets.sh         # Generate strong random secrets
    │   └── push-to-aws-secrets.sh      # Push secrets to AWS Secrets Manager
    └── terraform/
        ├── variables.tf                # Variable declarations
        └── terraform.tfvars.example    # Safe template (no real values)
```

> The Terraform infrastructure code lives in a **separate repository**: [`velura-infra-terraform`](../velura-infra-terraform)

---

## Local Development

### Prerequisites

- Docker & Docker Compose
- Python 3.11+ (for running tests locally)

### 1. Configure environment

```bash
cp .env.example .env
# Edit .env and fill in your values (see Environment Variables section)
```

### 2. Start the full stack

```bash
cd infra/docker
docker compose --env-file ../../.env up --build
```

This starts: MySQL, all 4 Flask services, Nginx frontend, Elasticsearch, Kibana, and Filebeat.

### 3. Access the app

| Service | URL |
|---|---|
| Frontend | http://localhost:8080 |
| Auth API | http://localhost:5001 |
| Catalog API | http://localhost:5002 |
| Rental API | http://localhost:5003 |
| Admin API | http://localhost:5004 |
| phpMyAdmin | http://localhost:8081 |
| Kibana | http://localhost:5601 |

### 4. Run tests locally

```bash
pip install -r services/auth/requirements.txt pytest
PYTHONPATH=. pytest services/auth/tests/ -v
```

---

## AWS Infrastructure (Terraform)

The cloud infrastructure is fully managed via Terraform in the [`velura-infra-terraform`](../velura-infra-terraform) directory.

### Resources provisioned

| Resource | Details |
|---|---|
| **VPC** | Custom VPC with public/private subnets across 2 AZs |
| **Subnets** | 2 public (ALB) + 2 private (ECS, RDS) |
| **NAT Gateway** | Allows private ECS tasks to reach ECR/internet |
| **ALB** | Path-based routing to all services |
| **ECS Cluster** | AWS Fargate (serverless containers) |
| **ECS Services** | auth, catalog, rental, admin, frontend, elasticsearch, kibana, filebeat |
| **ECR** | One private registry per service (keeps last 3 images) |
| **RDS** | MySQL 8.0 on `db.t3.micro`, private subnet |
| **Secrets Manager** | All passwords and keys — injected into ECS at runtime |
| **IAM** | Least-privilege execution + task roles |
| **CloudWatch** | Log groups for every ECS service (7-day retention) |
| **Security Groups** | ALB (public:80), backend (VPC-internal 5001–5004), RDS (backend only) |
| **Service Connect** | Internal DNS for service-to-service discovery |

### First-time deployment

```bash
cd velura-infra-terraform

# 1. Copy and fill in variables
cp terraform.tfvars.example terraform.tfvars
# Fill in: aws_account_id, db_password, jwt_secret_key, elastic_password, etc.

# 2. Initialize Terraform
terraform init

# 3. Create infrastructure (ECR + VPC + RDS + ECS cluster, no app images yet)
terraform apply

# 4. Push Docker images to ECR (after `terraform output ecr_urls`)
# Then update image_* variables in terraform.tfvars and run:
terraform apply
```

### After deployment

```bash
terraform output alb_url     # Your app's public URL
terraform output ecr_urls    # ECR registry URLs for each service
```

> **Security note:** Never commit `terraform.tfvars` — it contains sensitive values. Only `terraform.tfvars.example` is safe to commit.

---

## CI/CD Pipeline

The GitHub Actions pipeline (`.github/workflows/ci.yml`) runs on every push to `main`.

### Pipeline stages

```
push to main
    │
    ├── 1. detect-changes     Smart path filtering — only rebuild changed services
    │
    ├── 2. linting            Flake8 syntax check on all Python services
    │
    ├── 3. backend-tests      Pytest security & functional tests (Auth service)
    │
    ├── 4. build-and-deploy   Parallel matrix per service:
    │       ├── Docker build (with layer cache via GitHub Actions cache)
    │       ├── Trivy vulnerability scan (CRITICAL/HIGH — blocks on failure)
    │       ├── AWS ECR login
    │       └── Push image:sha + image:latest to ECR
    │
    └── 5. deploy-to-production
            └── aws ecs update-service --force-new-deployment (all services)
```

### Required GitHub Secrets

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | IAM user access key (CI deploy permissions) |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key |
| `AWS_REGION` | Target region (e.g. `us-east-1`) |

> Pull requests only run linting and tests — no builds or deployments.

---

## Observability — ELK Stack

All services are instrumented for centralized logging:

- **Filebeat** runs as a container, mounts the Docker socket, and ships logs from all containers with `co.elastic.logs/enabled=true` label.
- **Elasticsearch** stores and indexes the logs.
- **Kibana** provides a dashboard at `:5601` for searching, filtering, and visualizing logs by service.

Each service uses structured logging with `%(asctime)s %(levelname)s %(message)s` format, making log queries consistent across the entire platform.

---

## Security

- **Passwords** are hashed with `bcrypt` — never stored in plain text.
- **JWT tokens** are signed with a secret key from environment variables (never hardcoded).
- **Admin routes** verify both token validity and user role before executing.
- **All secrets** in production are stored in **AWS Secrets Manager** and injected into ECS task definitions at runtime — no plaintext in container environment.
- **Docker images** are scanned with **Trivy** on every build. CRITICAL/HIGH vulnerabilities block the pipeline.
- **RDS** is in a private subnet — not reachable from the public internet.
- **Backend ECS tasks** are in private subnets — only reachable via the ALB.
- **`.env` and `terraform.tfvars`** are in `.gitignore` — only example files are committed.

---

## Environment Variables

Copy `.env.example` to `.env` and fill in your values. Never commit `.env`.

| Variable | Description |
|---|---|
| `MYSQL_ROOT_PASSWORD` | MySQL root password |
| `MYSQL_USER` / `MYSQL_PASSWORD` | App database credentials |
| `MYSQL_DATABASE` | Database name |
| `JWT_SECRET_KEY` | Secret for signing JWT tokens (generate with `openssl rand -hex 32`) |
| `AUTH_SERVICE_PORT` | Auth service port (default: 5001) |
| `CATALOG_SERVICE_PORT` | Catalog service port (default: 5002) |
| `RENTAL_SERVICE_PORT` | Rental service port (default: 5003) |
| `ADMIN_SERVICE_PORT` | Admin service port (default: 5004) |
| `AUTH_SERVICE_URL` | Internal URL for service-to-service auth calls |
| `ELASTIC_PASSWORD` | Elasticsearch `elastic` user password |
| `KIBANA_PASSWORD` | Kibana system user password |
| `KIBANA_ENCRYPTION_KEY` | 32-char key for Kibana saved objects encryption |

> For AWS deployment, all of the above are stored in **AWS Secrets Manager** and automatically injected into ECS task definitions by Terraform.