data "aws_ami" "al2023" {
  count       = try(var.ec2.ami_id, null) == null && local.os == "al2023" ? 1 : 0
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
  owners   = ["amazon"]
  provider = aws.this
}
