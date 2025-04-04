resource "aws_vpc" "ecs_vpc" {
  cidr_block = var.vpc_definition.cidr_block
  
  tags = {
    Name = var.vpc_definition.vpc_name
  }
}

# Security Group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg"
  description = "Allow inbound access from ALB only"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.vpc_definition.vpc_name}-ecs-tasks-sg"
  }
}