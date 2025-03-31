resource "aws_lb" "this" {
  count              = try(var.load_balancer.type, null) == "application" || try(var.load_balancer.type, null) == "network" ? 1 : 0
  name               = "${substr("${local.scope.machine}-${local.purpose.machine}", 0, 24)}-${local.environment.machine}-lb"
  load_balancer_type = var.load_balancer.type
  security_groups    = try(var.load_balancer.type, null) == "application" || try(var.load_balancer.type, null) == "network" ? [aws_security_group.load_balancer[0].id] : null

  internal                         = try(var.load_balancer.internal, null)
  enable_cross_zone_load_balancing = try(var.load_balancer.enable_cross_zone_load_balancing, null)

  idle_timeout               = try(var.load_balancer.idle_timeout, null)
  enable_deletion_protection = try(var.load_balancer.enable_deletion_protection, null)
  enable_http2               = try(var.load_balancer.enable_http2, null)
  ip_address_type            = try(var.load_balancer.ip_address_type, null)
  drop_invalid_header_fields = try(var.load_balancer.drop_invalid_header_fields, null)

  dynamic "access_logs" {
    for_each = try(var.load_balancer.access_logs, null) != null ? [var.load_balancer.access_logs] : []
    content {
      enabled = try(access_logs.value.enabled, null)
      bucket  = try(access_logs.value.bucket, null)
      prefix  = try(access_logs.value.prefix, null)
    }
  }

  dynamic "subnet_mapping" {
    iterator = subnet_id
    for_each = { for idx, subnet_id in local.subnet.lb.ids : subnet_id => idx }
    content {
      subnet_id     = subnet_id.key
      allocation_id = (try(var.load_balancer.enable_elastic_ip, false) ? aws_eip.lb[subnet_id.value].id : null)
    }
  }

  tags     = local.tags
  provider = aws.this

  depends_on = [
    aws_eip.lb
  ]
}
