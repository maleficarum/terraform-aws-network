# VPC
resource "aws_vpc" "ecs_vpc" {
  cidr_block = var.vpc_definition.cidr_block
  
  tags = {
    Name = var.vpc_definition.vpc_name
    created-by = var.author
  }
}

# Security Group for ECS tasks (or EC2 instances)
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg"
  description = "Allow inbound access from ALB only"
  vpc_id      = aws_vpc.ecs_vpc.id

  # Ingress from ALB - only if ALB is created
  dynamic "ingress" {
    for_each = var.create_load_balancer ? [1] : []
    content {
      protocol        = "tcp"
      from_port       = 80
      to_port         = 80
      security_groups = [aws_security_group.public_security_group[0].id]
    }
  }

  # If no ALB, allow HTTP from anywhere (or specific CIDRs)
  dynamic "ingress" {
    for_each = !var.create_load_balancer ? [1] : []
    content {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = var.allowed_ingress_cidr  # Or use a variable for allowed CIDRs
    }
  }

  # HTTPS ingress if no ALB
  dynamic "ingress" {
    for_each = !var.create_load_balancer ? [1] : []
    content {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = var.allowed_ingress_cidr
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.vpc_definition.vpc_name}-ecs-tasks-sg"
    created-by = var.author
  }
}

# ALB Security Group - only created if ALB is needed
resource "aws_security_group" "public_security_group" {
  count = var.create_load_balancer ? 1 : 0
  
  name        = "alb-sg"
  description = "Allow HTTP and HTTPS traffic to ALB"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.allowed_ingress_cidr
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.allowed_ingress_cidr
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "alb-sg"
    created-by = var.author
  }
}

# Optional: Security Group for direct EC2 access (without ALB)
resource "aws_security_group" "direct_access" {
  count = !var.create_load_balancer ? 1 : 0
  
  name        = "direct-access-sg"
  description = "Security group for direct EC2/ECS access"
  vpc_id      = aws_vpc.ecs_vpc.id

  # SSH access (optional)
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.allowed_ingress_cidr
  }

  # HTTP access
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.allowed_ingress_cidr
  }

  # HTTPS access
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.allowed_ingress_cidr
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.vpc_definition.vpc_name}-direct-access-sg"
    created-by = var.author
  }
}