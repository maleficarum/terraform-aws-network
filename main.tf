resource "aws_vpc" "ecs_vpc" {
  cidr_block = var.vpc_definition.cidr_block
  
  tags = {
    Name = var.vpc_definition.vpc_name
  }
}

# Subnets
resource "aws_subnet" "public_subnet" {
  count = length(var.vpc_definition.public_subnets)
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = var.vpc_definition.public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecs_vpc.id
  
  tags = {
    Name = var.vpc_definition.internet_gateway_name
  }
}


# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "${var.vpc_definition.internet_gateway_name}-prt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_rt-association" {
  count = length(var.vpc_definition.public_subnets)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    #tfsec:ignore:aws-ec2-no-public-ingress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "alb-sg"
  }
}

# nosemgrep:terraform.aws.security.aws-elb-access-logs-not-enabled.aws-elb-access-logs-not-enabled
resource "aws_alb" "main_alb" {
  name               = "ecs-alb"
  subnets            = aws_subnet.public_subnet[*].id
  security_groups    = [aws_security_group.alb.id]
  #tfsec:ignore:aws-elb-alb-not-public
  internal           = false 
  load_balancer_type = "application"
  drop_invalid_header_fields = true
  
  tags = {
    Name = "ecs-alb"
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


# Target Group
resource "aws_alb_target_group" "app_target_group" {
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
    path                = "/"
    matcher             = "200-399"
  }
}

# Listener
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main_alb.arn
  port              = "80"
  #tfsec:ignore:aws-elb-http-not-used
  # nosemgrep:terraform.aws.security.insecure-load-balancer-tls-version.insecure-load-balancer-tls-version
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app_target_group.arn
  }
}
