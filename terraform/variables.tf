variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "clothes"
}

variable "aws_account_id" {
  description = "536697232354"
}

# ── RDS ──────────────────────────────────────────────────────────────────────
variable "db_username" {
  description = "RDS MySQL username"
  default     = "rental_user"
}

variable "db_password" {
  description = "RDS MySQL root password"
  sensitive   = true
}

variable "db_name" {
  description = "RDS MySQL database name"
  default     = "clothes_rental"
}

# ── Secrets ───────────────────────────────────────────────────────────────────
variable "jwt_secret_key" {
  description = "JWT signing secret"
  sensitive   = true
}

variable "elastic_password" {
  description = "Elasticsearch built-in elastic user password"
  sensitive   = true
}

variable "kibana_password" {
  description = "Kibana system user password"
  sensitive   = true
}

variable "kibana_encryption_key" {
  description = "32+ char random string for Kibana encryption"
  sensitive   = true
}

# ── Image URIs (empty on first apply, filled after docker push) ───────────────
variable "image_auth" { default = "" }
variable "image_catalog" { default = "" }
variable "image_rental" { default = "" }
variable "image_admin" { default = "" }
variable "image_frontend" { default = "" }
variable "image_elasticsearch" { default = "docker.elastic.co/elasticsearch/elasticsearch:8.12.0" }
variable "image_kibana" { default = "docker.elastic.co/kibana/kibana:8.12.0" }
variable "image_filebeat" { default = "" }