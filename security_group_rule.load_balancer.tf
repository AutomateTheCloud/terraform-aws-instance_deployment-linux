resource "aws_security_group_rule" "load_balancer" {
  count                    = try(var.load_balancer.type, null) == "application" || try(var.load_balancer.type, null) == "classic" || try(var.load_balancer.type, null) == "network" ? try(length(var.load_balancer.security_group_rules), 0) : 0
  security_group_id        = aws_security_group.load_balancer[0].id
  type                     = var.load_balancer.security_group_rules[count.index].type
  protocol                 = var.load_balancer.security_group_rules[count.index].protocol
  from_port                = var.load_balancer.security_group_rules[count.index].from_port
  to_port                  = var.load_balancer.security_group_rules[count.index].to_port
  cidr_blocks              = (can(cidrnetmask(var.load_balancer.security_group_rules[count.index].source)) ? [var.load_balancer.security_group_rules[count.index].source] : null)
  source_security_group_id = (can(cidrnetmask(var.load_balancer.security_group_rules[count.index].source)) ? null : var.load_balancer.security_group_rules[count.index].source)
  description              = try(var.load_balancer.security_group_rules[count.index].description, null)
  provider                 = aws.this
}

resource "aws_security_group_rule" "ec2_lb-ingress" {
  count                    = try(var.load_balancer.type, null) == "application" || try(var.load_balancer.type, null) == "classic" || try(var.load_balancer.type, null) == "network" ? 1 : 0
  security_group_id        = aws_security_group.ec2.id
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.load_balancer[0].id
  description              = "EC2 (${aws_security_group.ec2.name}) to LB (${aws_security_group.load_balancer[0].name})"
  provider                 = aws.this
}

resource "aws_security_group_rule" "ec2_lb-egress" {
  count                    = try(var.load_balancer.type, null) == "application" || try(var.load_balancer.type, null) == "classic" || try(var.load_balancer.type, null) == "network" ? 1 : 0
  security_group_id        = aws_security_group.ec2.id
  type                     = "egress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.load_balancer[0].id
  description              = "EC2 (${aws_security_group.ec2.name}) to LB (${aws_security_group.load_balancer[0].name})"
  provider                 = aws.this
}

resource "aws_security_group_rule" "lb_ec2-egress" {
  count                    = try(var.load_balancer.type, null) == "application" || try(var.load_balancer.type, null) == "classic" || try(var.load_balancer.type, null) == "network" ? 1 : 0
  security_group_id        = aws_security_group.load_balancer[0].id
  type                     = "egress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.ec2.id
  description              = "LB (${aws_security_group.load_balancer[0].name}) to LB (${aws_security_group.ec2.name})"
  provider                 = aws.this
}
