resource "aws_iam_instance_profile" "ec2" {
  name     = "${local.scope.abbr}-${local.purpose.abbr}-${local.environment.abbr}-${local.aws.region.abbr}-ec2"
  role     = aws_iam_role.ec2.name
  provider = aws.this
}
