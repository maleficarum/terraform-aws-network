# outputs.tf
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.ecs_vpc.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private_subnets[*].id
}

output "ecs_tasks_security_group_id" {
  description = "Security group ID for ECS tasks/EC2 instances"
  value       = aws_security_group.ecs_tasks.id
}

output "alb_security_group_id" {
  description = "Security group ID for ALB (if created)"
  value       = var.create_load_balancer ? aws_security_group.public_security_group[0].id : null
}

output "direct_access_security_group_id" {
  description = "Security group ID for direct access (if no ALB)"
  value       = !var.create_load_balancer ? aws_security_group.direct_access[0].id : null
}

output "alb_dns_name" {
  description = "DNS name of the ALB (if created)"
  value       = var.create_load_balancer ? aws_alb.public_main_alb[0].dns_name : null
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group (if created)"
  value       = var.create_load_balancer ? aws_alb_target_group.public_app_target_group[0].arn : null
}