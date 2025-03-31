resource "aws_lb_listener" "this" {
  for_each          = local.lb_listeners
  load_balancer_arn = aws_lb.this[0].id
  port              = try(each.value.frontend_port, null)
  protocol          = try(each.value.frontend_protocol, null)
  certificate_arn   = try(each.value.frontend_protocol, "") == "HTTPS" || try(each.value.frontend_protocol, "") == "TLS" ? try(var.certificate_arn, null) : null
  ssl_policy        = try(each.value.ssl_policy, null)
  alpn_policy       = try(each.value.alpn_policy, null)

  default_action {
    type             = try(each.value.type, null)
    target_group_arn = aws_lb_target_group.this[each.value.index_target_group].id

    dynamic "redirect" {
      for_each = try(each.value.type, null) == "redirect" ? [1] : []
      content {
        host        = try(each.value.redirect_host, null)
        path        = try(each.value.redirect_path, null)
        port        = try(each.value.redirect_port, null)
        protocol    = try(each.value.redirect_protocol, null)
        query       = try(each.value.redirect_query, null)
        status_code = try(each.value.redirect_status_code, null)
      }
    }

    dynamic "fixed_response" {
      for_each = try(each.value.type, null) == "fixed-response" ? [1] : []
      content {
        content_type = try(each.value.fixed_response_content_type, null)
        message_body = try(each.value.fixed_response_message_body, null)
        status_code  = try(each.value.fixed_response_status_code, null)
      }
    }
  }

  tags     = local.tags
  provider = aws.this
}
