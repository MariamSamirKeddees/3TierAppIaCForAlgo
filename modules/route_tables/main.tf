resource "aws_route_table" "public_rt" {
vpc_id         = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0" # Everything
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



resource "aws_route_table" "private_rt" {
vpc_id           = var.vpc_id
  tags = {
    Name = "mariam-pri-rt-IaC"
  }
}

resource "aws_route_table_association" "private_rt_assoc" {
  for_each       = toset(var.private_subnet_ids)

  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt.id
}


