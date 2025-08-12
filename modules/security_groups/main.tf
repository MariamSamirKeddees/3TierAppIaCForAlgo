# Step 1 - create empty SGs
resource "aws_security_group" "sg" {
  for_each = var.security_groups
  name     = "${each.key}"
  vpc_id   = var.vpc_id


  # Inline ingress rules
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null)
      security_groups  = lookup(ingress.value, "security_groups", null)
    }
  }

  # Inline egress rules
  dynamic "egress" {
    for_each = each.value.egress
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = lookup(egress.value, "cidr_blocks", null)
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", null)
      security_groups  = lookup(egress.value, "security_groups", null)
    }
  }

    tags = {
      Name = "${each.key}"
    }
}

# Step 2 - add rules after all SGs exist


# Ingress rules
#resource "aws_security_group_rule" "ingress" {
#  for_each = {
#    for sg_name, sg_data in var.security_groups :
#    "${sg_name}-ingress" => {
#      sg_id    = aws_security_group.sg[sg_name].id
#      rules    = sg_data.ingress #this extracts ingress rules from each sg_data
#    }
#  }
#
#  type              = "ingress"
#  from_port         = each.value.rules[0].from_port
#  to_port           = each.value.rules[0].to_port
#  protocol          = each.value.rules[0].protocol
#  security_group_id = each.value.sg_id
#  cidr_blocks       = try(each.value.rules[0].cidr_blocks, [])
#  source_security_group_id = try(
#    aws_security_group.sg[each.value.rules[0].sg_sources[0]].id,
#    null
#  )
#    depends_on = [aws_security_group.sg] 
#}
#
## Egress rules
#resource "aws_security_group_rule" "egress" {
#  for_each = {
#    for sg_name, sg_data in var.security_groups :
#    "${sg_name}-egress" => {
#      sg_id    = aws_security_group.sg[sg_name].id
#      rules    = sg_data.egress
#    }
#  }
#
#  type              = "egress"
#  from_port         = each.value.rules[0].from_port
#  to_port           = each.value.rules[0].to_port
#  protocol          = each.value.rules[0].protocol
#  security_group_id = each.value.sg_id
#  cidr_blocks       = each.value.rules[0].cidr_blocks
#}
