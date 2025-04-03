output "public_subnets" {
  value = aws_subnet.public_subnets[*].id
  description = "Public subnets"
}

output "ecs_tasks" {
  value = aws_security_group.ecs_tasks.id
  description = "ECS tasks list"
}

output "target_group_arn" {
  value = aws_alb_target_group.app_target_group.arn
  description = "APRN for ALB"
}

output "domain_name" {
  value = aws_alb.main_alb.dns_name
  description = "ALB public endpoint"
}