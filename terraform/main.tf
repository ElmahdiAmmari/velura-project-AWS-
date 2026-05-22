# ── CloudWatch Log Groups ─────────────────────────────────────────────────────
locals {
  services = [
    "auth", "catalog", "rental", "admin",
    "frontend", "elasticsearch", "kibana", "filebeat"
  ]
}

resource "aws_cloudwatch_log_group" "services" {
  for_each          = toset(local.services)
  name              = "/ecs/${var.project_name}/${each.key}"
  retention_in_days = 7
}

# ── ECS Cluster ───────────────────────────────────────────────────────────────
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}