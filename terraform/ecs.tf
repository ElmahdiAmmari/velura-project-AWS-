locals {
  secret_arn = aws_secretsmanager_secret.app.arn

  # Shorthand: inject a key from Secrets Manager as an env variable
  # Usage: local.s("KEY_NAME")
  s = { for k in [
    "DB_HOST", "DB_USER", "DB_PASS", "MYSQL_DATABASE", "MYSQL_PORT",
    "JWT_SECRET_KEY", "ELASTIC_PASSWORD", "KIBANA_PASSWORD",
    "KIBANA_ENCRYPTION_KEY", "AUTH_SERVICE_URL", "ELASTICSEARCH_HOSTS",
    "KIBANA_HOST"
  ] : k => "${local.secret_arn}:${k}::" }

  log = {
    logDriver = "awslogs"
    options = {
      "awslogs-region"        = var.aws_region
      "awslogs-stream-prefix" = "ecs"
    }
  }

  create_auth     = length(var.image_auth) > 0
  create_catalog  = length(var.image_catalog) > 0
  create_rental   = length(var.image_rental) > 0
  create_admin    = length(var.image_admin) > 0
  create_frontend = length(var.image_frontend) > 0
  create_filebeat = length(var.image_filebeat) > 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# AUTH SERVICE
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_ecs_task_definition" "auth" {
  count                    = local.create_auth ? 1 : 0
  family                   = "${var.project_name}-auth"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name         = "auth"
    image        = var.image_auth
    portMappings = [{ name = "auth-port", containerPort = 5001, protocol = "tcp" }]
    secrets = [
      { name = "MYSQL_HOST", valueFrom = local.s["DB_HOST"] },
      { name = "MYSQL_PORT", valueFrom = local.s["MYSQL_PORT"] },
      { name = "MYSQL_USER", valueFrom = local.s["DB_USER"] },
      { name = "MYSQL_PASSWORD", valueFrom = local.s["DB_PASS"] },
      { name = "MYSQL_DATABASE", valueFrom = local.s["MYSQL_DATABASE"] },
      { name = "JWT_SECRET_KEY", valueFrom = local.s["JWT_SECRET_KEY"] }
    ]
    environment = [
      { name = "AUTH_SERVICE_PORT", value = "5001" },
      { name = "FLASK_DEBUG", value = "0" }
    ]
    logConfiguration = merge(local.log, {
      options = merge(local.log.options, { "awslogs-group" = "/ecs/${var.project_name}/auth" })
    })
  }])
}

resource "aws_ecs_service" "auth" {
  count           = local.create_auth ? 1 : 0
  name            = "${var.project_name}-auth"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.auth[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.backend.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.auth.arn
    container_name   = "auth"
    container_port   = 5001
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn
    service {
      port_name      = "auth-port"
      discovery_name = "clothes-auth"
      client_alias { port = 5001 }
    }
  }

  depends_on = [aws_lb_listener.http]
}

# ═══════════════════════════════════════════════════════════════════════════════
# CATALOG SERVICE
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_ecs_task_definition" "catalog" {
  count                    = local.create_catalog ? 1 : 0
  family                   = "${var.project_name}-catalog"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name         = "catalog"
    image        = var.image_catalog
    portMappings = [{ name = "catalog-port", containerPort = 5002, protocol = "tcp" }]
    secrets = [
      { name = "MYSQL_HOST", valueFrom = local.s["DB_HOST"] },
      { name = "MYSQL_PORT", valueFrom = local.s["MYSQL_PORT"] },
      { name = "MYSQL_USER", valueFrom = local.s["DB_USER"] },
      { name = "MYSQL_PASSWORD", valueFrom = local.s["DB_PASS"] },
      { name = "MYSQL_DATABASE", valueFrom = local.s["MYSQL_DATABASE"] }
    ]
    environment = [
      { name = "CATALOG_SERVICE_PORT", value = "5002" },
      { name = "FLASK_DEBUG", value = "0" },
      { name = "AUTH_SERVICE_URL", value = "http://clothes-alb-608542139.us-east-1.elb.amazonaws.com/auth" }
    ]
    logConfiguration = merge(local.log, {
      options = merge(local.log.options, { "awslogs-group" = "/ecs/${var.project_name}/catalog" })
    })
  }])
}

resource "aws_ecs_service" "catalog" {
  count           = local.create_catalog ? 1 : 0
  name            = "${var.project_name}-catalog"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.catalog[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.backend.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.catalog.arn
    container_name   = "catalog"
    container_port   = 5002
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn
    service {
      port_name      = "catalog-port"
      discovery_name = "clothes-catalog"
      client_alias { port = 5002 }
    }
  }

  depends_on = [aws_lb_listener.http]
}

# ═══════════════════════════════════════════════════════════════════════════════
# RENTAL SERVICE
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_ecs_task_definition" "rental" {
  count                    = local.create_rental ? 1 : 0
  family                   = "${var.project_name}-rental"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name         = "rental"
    image        = var.image_rental
    portMappings = [{ name = "rental-port", containerPort = 5003, protocol = "tcp" }]
    secrets = [
      { name = "MYSQL_HOST", valueFrom = local.s["DB_HOST"] },
      { name = "MYSQL_PORT", valueFrom = local.s["MYSQL_PORT"] },
      { name = "MYSQL_USER", valueFrom = local.s["DB_USER"] },
      { name = "MYSQL_PASSWORD", valueFrom = local.s["DB_PASS"] },
      { name = "MYSQL_DATABASE", valueFrom = local.s["MYSQL_DATABASE"] },
      { name = "AUTH_SERVICE_URL", valueFrom = local.s["AUTH_SERVICE_URL"] }
    ]
    environment = [
      { name = "RENTAL_SERVICE_PORT", value = "5003" },
      { name = "FLASK_DEBUG", value = "0" }
    ]
    logConfiguration = merge(local.log, {
      options = merge(local.log.options, { "awslogs-group" = "/ecs/${var.project_name}/rental" })
    })
  }])
}

resource "aws_ecs_service" "rental" {
  count           = local.create_rental ? 1 : 0
  name            = "${var.project_name}-rental"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.rental[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.backend.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.rental.arn
    container_name   = "rental"
    container_port   = 5003
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn
    service {
      port_name      = "rental-port"
      discovery_name = "clothes-rental"
      client_alias { port = 5003 }
    }
  }

  depends_on = [aws_lb_listener.http]
}

# ═══════════════════════════════════════════════════════════════════════════════
# ADMIN SERVICE
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_ecs_task_definition" "admin" {
  count                    = local.create_admin ? 1 : 0
  family                   = "${var.project_name}-admin"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name         = "admin"
    image        = var.image_admin
    portMappings = [{ name = "admin-port", containerPort = 5004, protocol = "tcp" }]
    secrets = [
      { name = "MYSQL_HOST", valueFrom = local.s["DB_HOST"] },
      { name = "MYSQL_PORT", valueFrom = local.s["MYSQL_PORT"] },
      { name = "MYSQL_USER", valueFrom = local.s["DB_USER"] },
      { name = "MYSQL_PASSWORD", valueFrom = local.s["DB_PASS"] },
      { name = "MYSQL_DATABASE", valueFrom = local.s["MYSQL_DATABASE"] },
      { name = "AUTH_SERVICE_URL", valueFrom = local.s["AUTH_SERVICE_URL"] }
    ]
    environment = [
      { name = "ADMIN_SERVICE_PORT", value = "5004" },
      { name = "FLASK_DEBUG", value = "0" }
    ]
    logConfiguration = merge(local.log, {
      options = merge(local.log.options, { "awslogs-group" = "/ecs/${var.project_name}/admin" })
    })
  }])
}

resource "aws_ecs_service" "admin" {
  count           = local.create_admin ? 1 : 0
  name            = "${var.project_name}-admin"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.admin[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.backend.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.admin.arn
    container_name   = "admin"
    container_port   = 5004
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn
    service {
      port_name      = "admin-port"
      discovery_name = "clothes-admin"
      client_alias { port = 5004 }
    }
  }

  depends_on = [aws_lb_listener.http]
}

# ═══════════════════════════════════════════════════════════════════════════════
# FRONTEND
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_ecs_task_definition" "frontend" {
  count                    = local.create_frontend ? 1 : 0
  family                   = "${var.project_name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name         = "frontend"
    image        = var.image_frontend
    portMappings = [{ containerPort = 80, protocol = "tcp" }]
    # Frontend uses build args baked into the image at build time.
    # No runtime secrets needed here.
    logConfiguration = merge(local.log, {
      options = merge(local.log.options, { "awslogs-group" = "/ecs/${var.project_name}/frontend" })
    })
  }])
}

resource "aws_ecs_service" "frontend" {
  count           = local.create_frontend ? 1 : 0
  name            = "${var.project_name}-frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.frontend.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}

# ═══════════════════════════════════════════════════════════════════════════════
# ELASTICSEARCH
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_ecs_task_definition" "elasticsearch" {
  family                   = "${var.project_name}-elasticsearch"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024" # 1 vCPU
  memory                   = "2048" # 2 GB minimum for ES
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name  = "elasticsearch"
    image = var.image_elasticsearch
    portMappings = [
      { name = "es-port", containerPort = 9200, protocol = "tcp" },
      { containerPort = 9300, protocol = "tcp" }
    ]
    secrets = [
      { name = "ELASTIC_PASSWORD", valueFrom = local.s["ELASTIC_PASSWORD"] }
    ]
    environment = [
      { name = "discovery.type", value = "single-node" },
      { name = "xpack.security.enabled", value = "true" },
      { name = "xpack.security.http.ssl.enabled", value = "false" },
      { name = "xpack.security.transport.ssl.enabled", value = "false" },
      { name = "xpack.security.authc.api_key.enabled", value = "true" },
      { name = "ES_JAVA_OPTS", value = "-Xms512m -Xmx512m" }
    ]
    logConfiguration = merge(local.log, {
      options = merge(local.log.options, { "awslogs-group" = "/ecs/${var.project_name}/elasticsearch" })
    })
  }])
}

resource "aws_ecs_service" "elasticsearch" {
  name            = "${var.project_name}-elasticsearch"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.elasticsearch.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.elasticsearch.id]
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn
    service {
      port_name      = "es-port"
      discovery_name = "clothes-elasticsearch"
      client_alias { port = 9200 }
    }
  }

  depends_on = [aws_lb_listener.http]
}

# ═══════════════════════════════════════════════════════════════════════════════
# KIBANA
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_ecs_task_definition" "kibana" {
  family                   = "${var.project_name}-kibana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name         = "kibana"
    image        = var.image_kibana
    portMappings = [{ name = "kibana-port", containerPort = 5601, protocol = "tcp" }]
    secrets = [
      { name = "ELASTICSEARCH_PASSWORD", valueFrom = local.s["KIBANA_PASSWORD"] },
      { name = "XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY", valueFrom = local.s["KIBANA_ENCRYPTION_KEY"] },
      { name = "XPACK_SECURITY_ENCRYPTIONKEY", valueFrom = local.s["KIBANA_ENCRYPTION_KEY"] },
      { name = "XPACK_REPORTING_ENCRYPTIONKEY", valueFrom = local.s["KIBANA_ENCRYPTION_KEY"] }
    ]
    environment = [
      { name = "ELASTICSEARCH_HOSTS", value = "http://clothes-elasticsearch:9200" },
      { name = "ELASTICSEARCH_USERNAME", value = "kibana_system" }
    ]
    logConfiguration = merge(local.log, {
      options = merge(local.log.options, { "awslogs-group" = "/ecs/${var.project_name}/kibana" })
    })
  }])
}

resource "aws_ecs_service" "kibana" {
  name            = "${var.project_name}-kibana"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kibana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.kibana.id]
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn
    service {
      port_name      = "kibana-port"
      discovery_name = "clothes-kibana"
      client_alias { port = 5601 }
    }
  }

  depends_on = [aws_ecs_service.elasticsearch]
}

# ═══════════════════════════════════════════════════════════════════════════════
# FILEBEAT
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_ecs_task_definition" "filebeat" {
  count                    = local.create_filebeat ? 1 : 0
  family                   = "${var.project_name}-filebeat"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name  = "filebeat"
    image = var.image_filebeat
    secrets = [
      { name = "ELASTIC_PASSWORD", valueFrom = local.s["ELASTIC_PASSWORD"] }
    ]
    environment = [
      { name = "ELASTICSEARCH_HOSTS", value = "http://clothes-elasticsearch:9200" },
      { name = "KIBANA_HOST", value = "http://clothes-kibana:5601" }
    ]
    # Note: filebeat.yml must be baked into your custom Filebeat Docker image
    # since Fargate does not support bind mounts from the host.
    logConfiguration = merge(local.log, {
      options = merge(local.log.options, { "awslogs-group" = "/ecs/${var.project_name}/filebeat" })
    })
  }])
}

resource "aws_ecs_service" "filebeat" {
  count           = local.create_filebeat ? 1 : 0
  name            = "${var.project_name}-filebeat"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.filebeat[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.elasticsearch.id]
    assign_public_ip = false
  }

  depends_on = [aws_ecs_service.elasticsearch, aws_ecs_service.kibana]
}

# ═══════════════════════════════════════════════════════════════════════════════
# SERVICE DISCOVERY (so services find each other by name inside the VPC)
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_service_discovery_private_dns_namespace" "main" {
  name = "${var.project_name}.internal"
  vpc  = aws_vpc.main.id
}