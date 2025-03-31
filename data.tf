data "aws_kms_key" "data" {
  count    = try(var.ec2.kms_key_id, null) != null ? 1 : 0
  key_id   = var.ec2.kms_key_id
  provider = aws.this
}

data "aws_kms_key" "efs" {
  count    = try(var.efs_file_system.kms_key_id, null) != null ? 1 : 0
  key_id   = var.efs_file_system.kms_key_id
  provider = aws.this
}

data "aws_subnets" "ec2" {
  count = try(var.ec2.subnets_tag, null) != null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Network"
    values = [try(var.ec2.subnets_tag, "")]
  }
  provider = aws.this
}

data "aws_subnets" "load_balancer" {
  count = try(var.load_balancer.subnets_tag, null) != null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Network"
    values = [try(var.load_balancer.subnets_tag, "")]
  }
  provider = aws.this
}

data "aws_vpc" "this" {
  id       = var.ec2.vpc_id
  provider = aws.this
}

data "template_cloudinit_config" "userdata" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/${local.os}/initialize.sh.tmpl", {
      region     = local.aws.region.name
      stack_name = "${local.scope.machine}-${local.purpose.machine}-${local.environment.machine}-${local.aws.region.abbr}"
    })
  }

  dynamic "part" {
    iterator = file
    for_each = var.userdata_add_files
    content {
      content_type = "text/x-shellscript"
      content      = file(file.value)
    }
  }

  dynamic "part" {
    iterator = command
    for_each = var.userdata_add_commands
    content {
      content_type = "text/x-shellscript"
      content      = "#!/bin/bash -x\n${command.value}"
    }
  }
}
