resource "aws_eip" "lb" {
  count  = try(var.load_balancer.enable_elastic_ip, false) ? length(local.subnet.lb.ids) : 0
  domain = "vpc"
  tags = merge(
    local.tags,
    tomap({
      "Name" = "${substr("${local.scope.machine}-${local.purpose.machine}", 0, 24)}-${local.environment.machine}-lb-${count.index + 1}"
    })
  )
  provider = aws.this
}
