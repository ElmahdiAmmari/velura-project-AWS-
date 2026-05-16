variable "MYSQL_ROOT_PASSWORD" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
}

variable "MYSQL_HOST" {
  description = "MySQL hostname"
  type        = string
}

variable "MYSQL_PORT" {
  description = "MySQL port"
  type        = number
}

variable "MYSQL_USER" {
  description = "MySQL username"
  type        = string
}

variable "MYSQL_PASSWORD" {
  description = "MySQL app password"
  type        = string
  sensitive   = true
}

variable "MYSQL_DATABASE" {
  description = "MySQL database name"
  type        = string
}

variable "JWT_SECRET_KEY" {
  description = "JWT signing secret"
  type        = string
  sensitive   = true
}

variable "AUTH_SERVICE_PORT" {
  description = "Auth service port"
  type        = number
}

variable "CATALOG_SERVICE_PORT" {
  description = "Catalog service port"
  type        = number
}

variable "RENTAL_SERVICE_PORT" {
  description = "Rental service port"
  type        = number
}

variable "ADMIN_SERVICE_PORT" {
  description = "Admin service port"
  type        = number
}

variable "AUTH_SERVICE_URL" {
  description = "Auth service URL for inter-service communication"
  type        = string
}

variable "FRONTEND_AUTH_URL" {
  description = "Auth API URL used by frontend"
  type        = string
}

variable "FRONTEND_CATALOG_URL" {
  description = "Catalog API URL used by frontend"
  type        = string
}

variable "FRONTEND_RENTAL_URL" {
  description = "Rental API URL used by frontend"
  type        = string
}

variable "FRONTEND_ADMIN_URL" {
  description = "Admin API URL used by frontend"
  type        = string
}

variable "FLASK_DEBUG" {
  description = "Flask debug mode flag"
  type        = string
}

variable "ELASTIC_PASSWORD" {
  description = "Elasticsearch password"
  type        = string
  sensitive   = true
}

variable "ELASTICSEARCH_HOSTS" {
  description = "Elasticsearch hosts URL"
  type        = string
}

variable "KIBANA_PASSWORD" {
  description = "Kibana password"
  type        = string
  sensitive   = true
}

variable "KIBANA_ENCRYPTION_KEY" {
  description = "Kibana encryption key"
  type        = string
  sensitive   = true
}

variable "KIBANA_HOST" {
  description = "Kibana host URL"
  type        = string
}
