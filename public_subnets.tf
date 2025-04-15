# Subnets
resource "aws_subnet" "public_subnets" {
  count = var.vpc_definition.public_subnets
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = cidrsubnet(var.vpc_definition.cidr_block, 4, count.index + 1)
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
    Name = "${var.vpc_definition.internet_gateway_name}-pubrt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_rt_association" {
  count = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}