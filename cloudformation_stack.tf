resource "aws_cloudformation_stack" "this" {
  name = "${local.scope.machine}-${local.purpose.machine}-${local.environment.machine}-${local.aws.region.abbr}"
  template_body = templatefile("${path.module}/files/${local.os}/cloudformation.yaml.tmpl", {
    scope_name           = local.scope.name
    scope_abbr           = local.scope.abbr
    purpose_name         = local.purpose.name
    purpose_abbr         = local.purpose.abbr
    environment_name     = local.environment.name
    environment_abbr     = local.environment.abbr
    region_name          = local.aws.region.name
    region_abbr          = local.aws.region.abbr
    subnets              = local.subnet.ec2.ids
    tags                 = local.tags
    ami_id               = local.ami_id
    iam_instance_profile = aws_iam_instance_profile.ec2.arn
    security_group_id    = aws_security_group.ec2.id
    userdata             = data.template_cloudinit_config.userdata.rendered
    efs_file_system      = try(var.efs_file_system, null) != null ? var.efs_file_system : null
    ec2                  = var.ec2
    volume_data_disks    = local.volume_data_disks
    auto_scaling_group   = var.auto_scaling_group
    lb_identifier_string = local.lb_identifier_string
    lb_targets           = local.lb_targets
    codedeploy           = try(var.codedeploy, null) != null ? var.codedeploy : null
  })

  timeouts {
    create = try(var.timeouts.cloudformation.create, "30m")
    delete = try(var.timeouts.cloudformation.delete, "30m")
    update = try(var.timeouts.cloudformation.update, "60m")
  }

  tags     = local.tags
  provider = aws.this
}
