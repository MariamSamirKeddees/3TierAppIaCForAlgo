resource "aws_subnet" "public" {
  for_each = {for i, cidr in var.public_subnets : "mariam-pub-${i+1}-IaC" => cidr}

  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  map_public_ip_on_launch = true
  availability_zone = var.azs[
    (tonumber(regex("\\d+", each.key)) - 1) % length(var.azs)
  ]

  tags = {
    Name = each.key
  }


}

resource "aws_subnet" "private" {
  for_each = {for i, cidr in var.private_subnets : "mariam-pri-${i+1}-IaC" => cidr}

  vpc_id            = var.vpc_id
  cidr_block        = each.value
    availability_zone = var.azs[
    (tonumber(regex("\\d+", each.key)) - 1) % length(var.azs)
  ]

  tags = {
    Name = each.key
  }

}

