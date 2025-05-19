resource "aws_subnet" "private_subnets" {
  count             = var.vpc_definition.private_subnets
  cidr_block        = cidrsubnet(var.vpc_definition.cidr_block, 8, (count.index + 1) * 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.ecs_vpc.id

  tags = {
    Name = "private-subnet-${count.index}"
  }
}


resource "aws_route_table" "private" {
  count  = var.vpc_definition.private_subnets
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name = "${count.index}-priv-rt"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_eip" "eip" {
  count = length(aws_subnet.public_subnets)
  #vpc   = true

  tags = {
    Name = "EIP-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(aws_subnet.public_subnets)
  subnet_id     = aws_subnet.public_subnets[count.index].id
  allocation_id = aws_eip.eip[count.index].id

  tags = {
    Name = "nat-ateway-${data.aws_availability_zones.available.names[count.index]}"
  }
}