output "public_subnets" {
  value       = aws_subnet.public_subnets[*].id
  description = "Public subnets"
}

output "private_subnets" {
  value       = aws_subnet.private_subnets[*].id
  description = "Public subnets"
}

output "ecs_tasks" {
  value       = aws_security_group.ecs_tasks.id
  description = "ECS tasks list"
}

output "target_group_arn" {
  value       = aws_alb_target_group.public_app_target_group.arn
  description = "APRN for ALB"
}

output "public_alb_dns_name" {
  value       = aws_alb.public_main_alb.dns_name
  description = "Public DNS name on LB"
}

output "vpc" {
  value       = aws_vpc.ecs_vpc.id
  description = "VPC used"
}