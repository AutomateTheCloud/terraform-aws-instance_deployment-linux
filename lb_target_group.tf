resource "aws_lb_target_group" "this" {
  count = try(length(var.load_balancer.target_group), 0)
  name  = "${substr("${local.scope.machine}-${local.purpose.machine}", 0, 24)}-${local.environment.machine}-${count.index + 1}"

  vpc_id      = data.aws_vpc.this.id
  target_type = "instance"

  port             = try(var.load_balancer.target_group[count.index].backend_port, null)
  protocol         = try(var.load_balancer.target_group[count.index].backend_protocol, null)
  protocol_version = try(var.load_balancer.target_group[count.index].backend_protocol_version, null)

  deregistration_delay          = try(var.load_balancer.target_group[count.index].deregistration_delay, null)
  slow_start                    = try(var.load_balancer.target_group[count.index].slow_start, null)
  proxy_protocol_v2             = try(var.load_balancer.target_group[count.index].proxy_protocol_v2, null)
  load_balancing_algorithm_type = try(var.load_balancer.target_group[count.index].load_balancing_algorithm_type, null)
  preserve_client_ip            = try(var.load_balancer.target_group[count.index].preserve_client_ip, null)


  dynamic "health_check" {
    for_each = length(keys(try(var.load_balancer.target_group[count.index].health_check, {}))) == 0 ? [] : [try(var.load_balancer.target_group[count.index].health_check, {})]
    content {
      enabled             = try(health_check.value.enabled, null)
      interval            = try(health_check.value.interval, null)
      path                = try(health_check.value.path, null)
      port                = try(health_check.value.port, null)
      healthy_threshold   = try(health_check.value.healthy_threshold, null)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, null)
      timeout             = try(health_check.value.timeout, null)
      protocol            = try(health_check.value.protocol, null)
      matcher             = try(health_check.value.matcher, null)
    }
  }

  dynamic "stickiness" {
    for_each = length(keys(try(var.load_balancer.target_group[count.index].stickiness, {}))) == 0 ? [] : [try(var.load_balancer.target_group[count.index].stickiness, {})]
    content {
      enabled         = try(stickiness.value.enabled, null)
      type            = try(stickiness.value.type, null)
      cookie_name     = try(stickiness.value.cookie_name, null)
      cookie_duration = try(stickiness.value.cookie_duration, null)
    }
  }

  tags     = local.tags
  provider = aws.this
}
