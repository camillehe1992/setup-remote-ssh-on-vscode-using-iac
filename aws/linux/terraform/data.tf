# Data sources
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ssm_parameter" "al2023_ami" {
  count = var.instance_ami == null ? 1 : 0

  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  instance_ami = var.instance_ami != null ? trimspace(var.instance_ami) : data.aws_ssm_parameter.al2023_ami[0].value
}

# Get your public IP for SSH access
data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}


# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ec2_managed_prefix_list" "instance_connect" {
  name = "com.amazonaws.${data.aws_region.current.region}.ec2-instance-connect"
}
