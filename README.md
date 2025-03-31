# AWS - Instance Deployment - Linux - Terraform Module
Terraform module for deploying EC2 instances (Linux) behind an AutoscalingGroup (AutomateTheCloud model)
- Supports:
  - EFS
  - CodeDeploy
  - Application LoadBalancers
  - Network LoadBalancers

***

## Usage
```hcl
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
```

***

## Inputs
TODO

## Inputs (Details)
| Name | Description | Type | Default |
|------|-------------|:----:|:-------:|
| `details.scope` | (Required) Scope Name - What does this object belong to? (Organization Name, Project, etc) | `string` | |
| `details.scope_abbr` | (Optional) Scope [Abbreviation](#abbreviations) Override | `string` | |
| `details.purpose` | (Required) Purpose Name - What is the purpose or function of this object, or what does this object server? | `string` | |
| `details.purpose_abbr` | (Optional) Purpose [Abbreviation](#abbreviations) Override | `string` | |
| `details.environment` | (Required) Environment Name | `string` | |
| `details.environment_abbr` | (Optional) Environment [Abbreviation](#abbreviations) Override | `string` | |
| `details.additional_tags` | (Optional) [Additional Tags](#additional-tags) for resources | `map` | `[]` |

***

## Outputs
All outputs from this module are mapped to a single output named `metadata` to make it easier to capture all of the relevant metadata that would be useful when referenced by other stacks (requires only a single output reference in your code, instead of dozens!)

| Name | Description |
|:-----|:------------|
| `details.scope.name` | Scope name |
| `details.scope.abbr` | Scope abbreviation |
| `details.scope.machine` | Scope machine-friendly abbreviation |
| `details.purpose.name` | Purpose name |
| `details.purpose.abbr` | Purpose abbreviation |
| `details.purpose.machine` | Purpose machine-friendly abbreviation |
| `details.environment.name` | Environment name |
| `details.environment.abbr` | Environment abbreviation |
| `details.environment.machine` | Environment machine-friendly abbreviation |
| `details.tags` | Map of tags applied to all resources |

```hcl
metadata = {
  TODO
}
```

***

## Notes

### Abbreviations
* When generating resource names, the module converts each identifier to a more 'machine-friendly' abbreviated format, removing all special characters, replacing spaces with underscores (_), and converting to lowercase. Example: 'Demo - Module' => 'demo_module'
* Not all resource names allow underscores. When those are encountered, the detail identifier will have the underscore removed (test_example => testexample) automatically. This machine-friendly abbreviation is referred to as 'machine' within the module.
* The abbreviations can be overridden by suppling the abbreviated names (ie: scope_abbr). This is useful when you have a long name and need the created resource names to be shorter. Some resources in AWS have shorter name constraints than others, or you may just prefer it shorter. NOTE: If specifying the Abbreviation, be sure to follow the convention of no spaces and no special characters (except for underscore), otherwise resoure creation may fail.

### Additional Tags
* You can specify additional tags for resources by adding to the `details.additional_tags` map.
```
additional_tags = {
  "Example"         = "Extra Tag"
  "Project"         = "Project Name"
  "CostCenter"      = "123456"
}
```

### Security Group Rules
- TODO: info about Security Group Rules
```
security_group_rules = [
  {
    type        = "ingress"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    source      = "192.168.1.0/24"
    description = "Allow All"
  },
  {
    type        = "ingress"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    source      = "192.168.2.0/24"
    description = "Allow All"
  },
  {
    type        = "egress"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    source      = "0.0.0.0/0"
    description = "Allow All"
  }
]
```

### CodeDeploy Details
- TODO: info about CodeDeploy

### EFS File System Details
- TODO: info about EFS

### LoadBalancer Details
- TODO: info about LoadBalancers

***

## Terraform Versions
Terraform ~> 1.11.0 is supported.

## Provider Versions
| Name | Version |
|------|---------|
| aws | `~> 5.93` |
