data "aws_ami" "amzn2" {
  count       = try(var.ec2.ami_id, null) == null && local.os == "al2023" ? 1 : 0
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
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
