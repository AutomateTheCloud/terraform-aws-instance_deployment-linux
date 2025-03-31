output "metadata" {
  description = "Metadata"
  value = {
    details = {
      scope = {
        name    = local.scope.name
        abbr    = local.scope.abbr
        machine = local.scope.machine
      }
      purpose = {
        name    = local.purpose.name
        abbr    = local.purpose.abbr
        machine = local.purpose.machine
      }
      environment = {
        name    = local.environment.name
        abbr    = local.environment.abbr
        machine = local.environment.machine
      }
      tags = local.tags
    }

    aws = {
      account = {
        id = local.aws.account.id
      }
      region = {
        name        = local.aws.region.name
        abbr        = local.aws.region.abbr
        description = local.aws.region.description
      }
    }

    cloudformation = {
      stack = aws_cloudformation_stack.this
    }

    cloudwatch = {
      log_group = {
        codedeploy = try(aws_cloudwatch_log_group.codedeploy)
      }
    }

    codedeploy = try(var.codedeploy, null) != null ? {
      app              = try(var.codedeploy.app, null)
      deployment_group = try(aws_codedeploy_deployment_group.this[0], null)
    } : null

    eip = try(var.load_balancer.enable_elastic_ip, false) ? {
      lb = try(aws_eip.lb[*], null)
    } : null

    iam = {
      role = {
        ec2 = aws_iam_role.ec2
      }
      instance_profile = {
        ec2 = aws_iam_instance_profile.ec2
      }
    }

    kms = {
      data = try(data.aws_kms_key.data[0], null)
      efs  = try(data.aws_kms_key.efs[0], null)
    }

    load_balancer = try(aws_lb.this[0], aws_elb.this[0], null)

    security_group = {
      ec2           = try(aws_security_group.ec2, null)
      load_balancer = try(aws_security_group.load_balancer[0], null)
    }
  }
}
