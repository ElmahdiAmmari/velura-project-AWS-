output "alb_url" {
  description = "Open this in your browser"
  value       = "http://${aws_lb.main.dns_name}"
}

output "rds_endpoint" {
  description = "MySQL RDS host (internal use only)"
  value       = aws_db_instance.mysql.address
  sensitive   = true
}

output "ecr_urls" {
  description = "ECR image URLs — push your images here"
  value = {
    for name, repo in aws_ecr_repository.services :
    name => repo.repository_url
  }
}

output "ecs_service_arns" {
  description = "ARNs of all ECS services"
  value = {
    auth          = length(aws_ecs_service.auth) > 0 ? aws_ecs_service.auth[0].id : ""
    catalog       = length(aws_ecs_service.catalog) > 0 ? aws_ecs_service.catalog[0].id : ""
    rental        = length(aws_ecs_service.rental) > 0 ? aws_ecs_service.rental[0].id : ""
    admin         = length(aws_ecs_service.admin) > 0 ? aws_ecs_service.admin[0].id : ""
    frontend      = length(aws_ecs_service.frontend) > 0 ? aws_ecs_service.frontend[0].id : ""
    elasticsearch = aws_ecs_service.elasticsearch.id
    kibana        = aws_ecs_service.kibana.id
    filebeat      = length(aws_ecs_service.filebeat) > 0 ? aws_ecs_service.filebeat[0].id : ""
  }
}

output "internal_service_urls" {
  description = "How services address each other inside the VPC"
  value = {
    auth          = "http://clothes-auth:5001"
    catalog       = "http://clothes-catalog:5002"
    rental        = "http://clothes-rental:5003"
    admin         = "http://clothes-admin:5004"
    elasticsearch = "http://clothes-elasticsearch:9200"
    kibana        = "http://clothes-kibana:5601"
  }
}