resource "aws_security_group" "load_balancer" {
  count                  = try(var.load_balancer.type, null) == "application" || try(var.load_balancer.type, null) == "classic" || try(var.load_balancer.type, null) == "network" ? 1 : 0
  name                   = "${local.scope.abbr}-${local.purpose.abbr}-${local.environment.abbr}-${local.aws.region.abbr}-lb"
  description            = "${local.scope.name} - ${local.purpose.name} [${local.environment.name}] (${local.aws.region.name}): Load Balancer"
  vpc_id                 = data.aws_vpc.this.id
  revoke_rules_on_delete = true
  tags = merge(
    local.tags,
    tomap({
      "Name" = "${local.scope.abbr}-${local.purpose.abbr}-${local.environment.abbr}-${local.aws.region.abbr}-lb"
    })
  )
  provider = aws.this
}
