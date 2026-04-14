# ALB - only if create_load_balancer is true
resource "aws_alb" "public_main_alb" {
  count = var.create_load_balancer ? 1 : 0
  
  name               = "ecs-alb"
  subnets            = aws_subnet.public_subnets[*].id
  security_groups    = [aws_security_group.public_security_group[0].id]
  internal           = false 
  load_balancer_type = "application"
  drop_invalid_header_fields = true
  
  tags = {
    Name = "ecs-alb"
    created-by = var.author
  }
}

# Target Group
resource "aws_alb_target_group" "public_app_target_group" {
  count = var.create_load_balancer ? 1 : 0
  
  name        = "ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ecs_vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = var.health_check_application
    matcher             = "200-399"
  }
}

# HTTP Listener (redirect to HTTPS)
resource "aws_alb_listener" "public_http" {
  count = var.create_load_balancer ? 1 : 0
  
  load_balancer_arn = aws_alb.public_main_alb[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_alb_listener" "public_https" {
  count = var.create_load_balancer ? 1 : 0
  
  load_balancer_arn = aws_alb.public_main_alb[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn  # Add this variable
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.public_app_target_group[0].arn
  }
}