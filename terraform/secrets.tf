resource "aws_secretsmanager_secret" "app" {
  name                    = "${var.project_name}/app-secrets"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id

  secret_string = jsonencode({
    DB_HOST               = aws_db_instance.mysql.address
    DB_USER               = var.db_username
    DB_PASS               = var.db_password
    MYSQL_DATABASE        = var.db_name
    MYSQL_PORT            = "3306"
    JWT_SECRET_KEY        = var.jwt_secret_key
    ELASTIC_PASSWORD      = var.elastic_password
    KIBANA_PASSWORD       = var.kibana_password
    KIBANA_ENCRYPTION_KEY = var.kibana_encryption_key

    # Internal service URLs (used by frontend + inter-service calls)
    AUTH_SERVICE_URL    = "http://clothes-auth:5001"
    CATALOG_SERVICE_URL = "http://clothes-catalog:5002"
    RENTAL_SERVICE_URL  = "http://clothes-rental:5003"
    ADMIN_SERVICE_URL   = "http://clothes-admin:5004"
    ELASTICSEARCH_HOSTS = "http://clothes-elasticsearch:9200"
    KIBANA_HOST         = "http://clothes-kibana:5601"

    # Frontend build args (ALB URL injected at build time — update after first apply)
    FRONTEND_AUTH_URL    = "http://${aws_lb.main.dns_name}/auth"
    FRONTEND_CATALOG_URL = "http://${aws_lb.main.dns_name}/catalog"
    FRONTEND_RENTAL_URL  = "http://${aws_lb.main.dns_name}/rental"
    FRONTEND_ADMIN_URL   = "http://${aws_lb.main.dns_name}/admin"
  })

  depends_on = [aws_db_instance.mysql, aws_lb.main]
}