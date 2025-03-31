data "aws_ami" "ubuntu22" {
  count = try(var.ec2.ami_id, null) == null && local.os == "ubuntu22" ? 1 : 0

  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
  owners   = ["099720109477"]
  provider = aws.this
}
