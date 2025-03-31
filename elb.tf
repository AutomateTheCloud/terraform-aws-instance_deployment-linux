resource "aws_elb" "this" {
  count                       = try(var.load_balancer.type, null) == "classic" ? 1 : 0
  name                        = "${substr("${local.scope.machine}-${local.purpose.machine}", 0, 24)}-${local.environment.machine}-lb"
  subnets                     = local.subnet.lb.ids
  security_groups             = [aws_security_group.load_balancer[0].id]
  internal                    = try(var.load_balancer.internal, null)
  cross_zone_load_balancing   = try(var.load_balancer.enable_cross_zone_load_balancing, null)
  idle_timeout                = try(var.load_balancer.idle_timeout, null)
  connection_draining         = try(var.load_balancer.connection_draining, null)
  connection_draining_timeout = try(var.load_balancer.connection_draining_timeout, null)

  dynamic "access_logs" {
    for_each = try(var.load_balancer.access_logs, null) != null ? [var.load_balancer.access_logs] : []
    content {
      enabled       = try(access_logs.value.enabled, null)
      bucket        = try(access_logs.value.bucket, null)
      bucket_prefix = try(access_logs.value.prefix, null)
      interval      = try(access_logs.value.interval, null)
    }
  }

  dynamic "health_check" {
    for_each = try(var.load_balancer.health_check, null) != null ? [var.load_balancer.health_check] : []
    content {
      interval            = try(health_check.value.interval, null)
      target              = try(health_check.value.target, null)
      healthy_threshold   = try(health_check.value.healthy_threshold, null)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, null)
      timeout             = try(health_check.value.timeout, null)
    }
  }

  dynamic "listener" {
    iterator = listener
    for_each = try(var.load_balancer.listeners, null) != null ? var.load_balancer.listeners : []
    content {
      lb_port            = listener.value.frontend_port
      lb_protocol        = listener.value.frontend_protocol
      instance_port      = listener.value.backend_port
      instance_protocol  = listener.value.backend_protocol
      ssl_certificate_id = try(listener.value.frontend_protocol, "") == "HTTPS" ? try(var.certificate_arn, null) : null
    }
  }

  tags     = local.tags
  provider = aws.this
}

resource "aws_lb_ssl_negotiation_policy" "this" {
  count         = try(var.load_balancer.type, null) == "classic" ? try(length(var.load_balancer.ssl.frontend_ports), 0) : 0
  name          = "${substr("${local.scope.machine}-${local.purpose.machine}", 0, 24)}-${local.environment.machine}-ssl-${var.load_balancer.ssl.frontend_ports[count.index]}"
  load_balancer = aws_elb.this[0].id
  lb_port       = var.load_balancer.ssl.frontend_ports[count.index]

  attribute {
    name  = "Reference-Security-Policy"
    value = try(var.load_balancer.ssl.policy, null)
  }
  provider = aws.this
}
