resource "aws_security_group_rule" "efs-ingress" {
  count                    = try(var.efs_file_system, null) != null ? 1 : 0
  security_group_id        = var.efs_file_system.security_group_id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 2049
  to_port                  = 2049
  source_security_group_id = aws_security_group.ec2.id
  description              = "Access: ${aws_security_group.ec2.name}"
  provider                 = aws.this
}

resource "aws_security_group_rule" "efs-egress" {
  count                    = try(var.efs_file_system, null) != null ? 1 : 0
  security_group_id        = var.efs_file_system.security_group_id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 2049
  to_port                  = 2049
  source_security_group_id = aws_security_group.ec2.id
  description              = "Access: ${aws_security_group.ec2.name}"
  provider                 = aws.this
}
