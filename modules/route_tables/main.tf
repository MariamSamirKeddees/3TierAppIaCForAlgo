########################
# Public Route Table
########################
resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "mariam-pub-rt-IaC"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  for_each       = toset(var.public_subnet_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.public_rt.id
}

########################
# Private Route Tables (with NAT per AZ)
########################
resource "aws_route_table" "private_rt_nat" {
  for_each = var.az_to_public_subnet
  vpc_id   = var.vpc_id

  tags = {
    Name = "mariam-private-rt-${each.key}-IaC"
  }
}

resource "aws_route" "private_nat_route" {
  for_each               = var.az_to_public_subnet
  route_table_id         = aws_route_table.private_rt_nat[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_ids[each.key]
}

resource "aws_route_table_association" "private_rt_be_nat_assoc" {
  for_each       = zipmap(var.azs, var.be_subnet_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt_nat[each.key].id
}

resource "aws_route_table_association" "private_rt_fe_nat_assoc" {
  for_each       = zipmap(var.azs, var.fe_subnet_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt_nat[each.key].id
}
