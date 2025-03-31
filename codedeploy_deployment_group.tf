resource "aws_codedeploy_deployment_group" "this" {
  count                  = try(var.codedeploy, null) != null ? 1 : 0
  app_name               = var.codedeploy.app.name
  deployment_group_name  = "${local.scope.abbr}-${local.purpose.abbr}-${local.environment.abbr}-${local.aws.region.abbr}"
  service_role_arn       = var.codedeploy.app.iam_role
  autoscaling_groups     = ["${local.scope.abbr}-${local.purpose.abbr}-${local.environment.abbr}-${local.aws.region.abbr}"]
  deployment_config_name = lookup(var.codedeploy, "deployment_config", null)

  deployment_style {
    deployment_option = try(var.load_balancer, null) != null ? "WITH_TRAFFIC_CONTROL" : "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  dynamic "load_balancer_info" {
    for_each = try(var.load_balancer.type, null) == "application" || try(var.load_balancer.type, null) == "network" ? (try(var.load_balancer, null) != null ? [1] : []) : []
    content {
      target_group_info {
        name = aws_lb_target_group.this[0].name
      }
    }
  }

  dynamic "load_balancer_info" {
    for_each = try(var.load_balancer.type, null) == "classic" ? (try(var.load_balancer, null) != null ? [1] : []) : []
    content {
      elb_info {
        name = aws_elb.this[0].name
      }
    }
  }

  auto_rollback_configuration {
    enabled = true
    events = [
      "DEPLOYMENT_FAILURE",
      "DEPLOYMENT_STOP_ON_ALARM"
    ]
  }
  depends_on = [
    aws_cloudformation_stack.this
  ]
  provider = aws.this
}