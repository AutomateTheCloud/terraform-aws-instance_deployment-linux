terraform {
  required_version = "~> 1.11.0"
}

##-----------------------------------------------------------------------------
# Providers
provider "aws" {
  alias  = "example"
  region = "us-east-1"
}

##-----------------------------------------------------------------------------
# Module: Instance Deployment
module "instance_deployment" {
  source    = "../"
  providers = { aws.this = aws.example }

  details = {
    scope               = "Demo"
    purpose             = "Instance Deployment - Linux"
    environment         = "prd"
    additional_tags = {
      "Project"         = "Project Name"
      "ProjectID"       = "123456789"
      "Contact"         = "David Singer - david.singer@example.com"
    }
  }

  ec2 = {
    vpc_id     = "vpc-0123456789abcdef0"
    os = "al2023"
    instance_types = [
      {type = "m7.large",  weighted_capacity = 1}
    ]
    volume = {
      root = {
        size_gb  = 20
      }
      data = {
        size_gb  = 20
        count    = 1
      }
      swap = {
        size_mb = 4096
      }
    }
    security_group_rules = [
      {
        type        = "egress"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        source      = "0.0.0.0/0"
        description = "Allow All"
      },
      {
        type        = "ingress"
        protocol    = "tcp"
        from_port   = 22
        to_port     = 22
        source      = "10.0.0.0/8"
        description = "Corporate Network Access"
      },
      {
        type        = "ingress"
        protocol    = "tcp"
        from_port   = 7654
        to_port     = 7654
        source      = "10.0.0.0/8"
        description = "Application Access"
      }
    ]
    subnets              = []
    subnets_tag          = "private"
    cloudwatch_retention = 30
  }

  auto_scaling_group = {
    desired_capacity         = 0
    min_size                 = 0
    max_size                 = 20
    ondemand_base_capacity   = 1
    ondemand_percentage      = 100
    spot_allocation_strategy        = "lowest-price"
    cooldown_period                 = 300
    health_check_grace_period       = 300
    update_timeout                  = "PT10M"
    update_min_in_service           = 0
    update_max_batch_size           = 8
    update_wait_on_resource_signals = true
    max_instance_lifetime           = 0
  }

  load_balancer = {
    type                             = "network"
    subnets                          = []
    subnets_tag                      = "public"
    internal                         = false
    enable_cross_zone_load_balancing = true
    enable_elastic_ip                = true
    target_group = [
      {
        backend_port                  = 7654
        backend_protocol             = "TCP"
        deregistration_delay          = 0
        slow_start                    = 0
        proxy_protocol_v2             = false
        preserve_client_ip            = true
        health_check = {
          enabled             = true
          interval            = 30
          port                = "traffic-port"
          healthy_threshold   = 2
          unhealthy_threshold = 2
          protocol            = "TCP"
        }
        listeners = [
          {
            frontend_port        = 7654
            frontend_protocol    = "TCP"
            type                 = "forward"
          }
        ]
      }
    ]
    access_logs = {
      enabled = true
      bucket  = "logs-use1-bucket"
      prefix  = "lb"
    }
  }
}

##-----------------------------------------------------------------------------
# Outputs
output "metadata" {
  description = "Metadata"
  value = module.instance_deployment.metadata
}
