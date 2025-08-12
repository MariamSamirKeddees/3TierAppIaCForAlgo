locals {
  az_to_public_subnet = zipmap(var.azs, var.public_subnet_ids)
  # this "zipmap" takes two lists and glue them together into a map 
  #{
    # "1a_az" = "public_sub1_id"
    # "1b_az" = "public_sub2_id"
  #}
}

resource "aws_eip" "nat_eip" {
  for_each = local.az_to_public_subnet #looping on az_to_public_subs local
  #vpc      = true
  tags = { Name = "mariam-eip-${each.key}-IaC" }
}

resource "aws_nat_gateway" "nat" {
  for_each     = local.az_to_public_subnet
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = each.value

  tags = { Name = "mariam-nat-${each.key}-IaC" }
}
