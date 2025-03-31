resource "aws_cloudwatch_log_group" "codedeploy" {
  count             = try(length(var.codedeploy.app.cloudwatch_log_group_names), 0)
  name              = "/${local.scope.abbr}/${local.purpose.abbr}/${local.environment.abbr}/application/${var.codedeploy.app.name}/${var.codedeploy.app.cloudwatch_log_group_names[count.index]}"
  retention_in_days = try(var.codedeploy.cloudwatch_retention, 30)
  tags              = local.tags
  provider          = aws.this
}
