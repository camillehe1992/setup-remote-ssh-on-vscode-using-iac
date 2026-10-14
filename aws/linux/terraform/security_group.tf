# Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for remote SSH development"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# SSH ingress rule
resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = length(var.allowed_ssh_cidr_blocks) > 0 ? var.allowed_ssh_cidr_blocks : ["${chomp(data.http.myip.response_body)}/32"]
  security_group_id = aws_security_group.ec2_sg.id
  description       = "SSH access"
}

# All outbound traffic
resource "aws_security_group_rule" "all_outbound" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  #trivy:ignore:AVD-AWS-0104
  cidr_blocks = ["0.0.0.0/0"]
  #trivy:ignore:AVD-AWS-0104
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.ec2_sg.id
  description       = "All outbound traffic"
}
