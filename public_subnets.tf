# Subnets
resource "aws_subnet" "public_subnets" {
  count = var.vpc_definition.public_subnets
  
  # Start at netnum 0 for first public subnet
  cidr_block = cidrsubnet(var.vpc_definition.cidr_block, 4, count.index)
  # Result: 10.0.0.0/20
  
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id = aws_vpc.ecs_vpc.id
  
  tags = {
    Name = "public-subnet-${count.index}"
    created-by = var.author
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecs_vpc.id
  
  tags = {
    Name = var.vpc_definition.internet_gateway_name
    created-by = var.author
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
    Name = "${var.vpc_definition.internet_gateway_name}-pubrt"
    created-by = var.author
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_rt_association" {
  count = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}