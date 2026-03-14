# EC2 Instance (Spot or On-Demand)
resource "aws_instance" "ec2" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  availability_zone      = data.aws_availability_zones.available.names[0]

  instance_market_options {
    market_type = var.use_spot_instance ? "spot" : "on-demand"
    spot_options {
      max_price                      = var.spot_instance_max_price
      spot_instance_type             = var.use_spot_instance ? "persistent" : "one-time"
      instance_interruption_behavior = var.use_spot_instance ? "stop" : "terminate"
    }
  }

  root_block_device {
    volume_type = var.ebs_volume_type
    volume_size = var.root_volume_size
    encrypted   = true
    tags = {
      Name = "${var.project_name}-root-volume"
      Type = "root"
    }
  }

  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"

  }

  monitoring = var.enable_monitoring

  tags = {
    Name = "${var.project_name}-ec2-instance"
  }
}

# Data EBS Volume
resource "aws_ebs_volume" "data_volume" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type
  iops              = var.ebs_volume_type == "gp3" ? var.ebs_volume_iops : null
  throughput        = var.ebs_volume_type == "gp3" ? var.ebs_volume_throughput : null
  encrypted         = true

  tags = {
    Name = "${var.project_name}-data-volume"
  }
}

# Attach EBS volume to instance
resource "aws_volume_attachment" "data_volume_attachment" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.data_volume.id
  instance_id = aws_instance.ec2.id

  # Prevent attachment issues during destroy
  skip_destroy = false
}
