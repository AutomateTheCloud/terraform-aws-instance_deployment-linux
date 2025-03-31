variable "auto_scaling_group" {
  description = "Auto Scaling Group"
  type        = any
  default     = null
}

variable "certificate_arn" {
  description = "Certificate ARN"
  type        = string
  default     = null
}

variable "codedeploy" {
  description = "CodeDeploy"
  type        = any
  default     = null
}

variable "ec2" {
  description = "EC2"
  type        = any
  default     = null
}

variable "efs_file_system" {
  description = "Elastic File System"
  type        = any
  default     = null
}

variable "load_balancer" {
  description = "Load Balancer"
  type        = any
  default     = null
}

variable "timeouts" {
  description = "Timeouts"
  type        = any
  default = {
    cloudformation = {
      create = "30m"
      delete = "30m"
      update = "60m"
    }
  }
}

variable "userdata_add_commands" {
  description = "UserData (Additional): Command"
  type        = list(any)
  default     = []
}

variable "userdata_add_files" {
  description = "UserData (Additional): File"
  type        = list(any)
  default     = []
}

resource "null_resource" "validate-os" {
  lifecycle {
    precondition {
      condition     = contains(["al2023", "amzn2", "ubuntu22", "ubuntu24"], try(var.ec2.os, ""))
      error_message = "Operating System not specified (var.ec2.os)"
    }
  }
}
