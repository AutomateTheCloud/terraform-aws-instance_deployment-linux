locals {
  ami_id = try(var.ec2.ami_id, data.aws_ami.al2023[0].id, data.aws_ami.amzn2[0].id, data.aws_ami.ubuntu22[0].id, data.aws_ami.ubuntu24[0].id)
  os     = try(var.ec2.os, "")

  inspector_rules_package_arns_default = ["common_vulnerabilities_and_exposures", "network_reachability", "security_best_practices"]

  lb_listeners = try(var.load_balancer.type, null) == "application" || try(var.load_balancer.type, null) == "network" ? (try(length(var.load_balancer), 0) > 0 ? merge(flatten([
    for index_target_group, group in var.load_balancer.target_group : [
      for k, listeners in group : {
        for index_listener, listener in listeners : join(".", [index_target_group, index_listener]) => merge({ index_target_group = index_target_group }, { index_listener = index_listener }, listener)
      }
      if k == "listeners"
    ]
  ])...) : {}) : {}

  lb_identifier_string = try(var.load_balancer.type, null) == "application" || try(var.load_balancer.type, null) == "network" ? "TargetGroupARNs" : (try(var.load_balancer.type, null) == "classic" ? "LoadBalancerNames" : null)
  lb_targets           = try(var.load_balancer.type, null) == "application" || try(var.load_balancer.type, null) == "network" ? jsonencode(try(aws_lb_target_group.this[*].id, null)) : (try(var.load_balancer.type, null) == "classic" ? jsonencode(try(aws_elb.this[*].name, null)) : null)

  subnet = {
    ec2 = {
      ids = try(var.ec2.subnets_tag, "") != "" ? distinct(compact(concat(tolist(data.aws_subnets.ec2[0].ids), try(var.ec2.subnets, [])))) : try(var.ec2.subnets, null)
    }
    lb = {
      ids = try(var.load_balancer.subnets_tag, "") != "" ? distinct(compact(concat(tolist(data.aws_subnets.load_balancer[0].ids), try(var.load_balancer.subnets, [])))) : try(var.load_balancer.subnets, null)
    }
  }

  volume_data_disks = try(compact([for volume in range(var.ec2.volume.data.count) : lookup(local.volume_data_disk_lookup, volume, "")]), [])
  volume_data_disk_lookup = {
    0  = "/dev/sdb"
    1  = "/dev/sdc"
    2  = "/dev/sdd"
    3  = "/dev/sde"
    4  = "/dev/sdf"
    5  = "/dev/sdg"
    6  = "/dev/sdh"
    7  = "/dev/sdi"
    8  = "/dev/sdj"
    9  = "/dev/sdk"
    10 = "/dev/sdl"
    11 = "/dev/sdm"
    12 = "/dev/sdn"
    13 = "/dev/sdo"
    14 = "/dev/sdp"
    15 = "/dev/sdq"
    16 = "/dev/sdr"
    17 = "/dev/sds"
    18 = "/dev/sdt"
    19 = "/dev/sdu"
    20 = "/dev/sdv"
    21 = "/dev/sdw"
    22 = "/dev/sdx"
    23 = "/dev/sdy"
    24 = "/dev/sdz"
  }
}
