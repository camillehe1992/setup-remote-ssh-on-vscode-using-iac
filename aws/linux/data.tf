# Data sources
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

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
