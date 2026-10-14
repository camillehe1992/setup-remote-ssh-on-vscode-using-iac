output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2.id
}

output "availability_zone" {
  description = "Availability zone of the EC2 instance"
  value       = aws_instance.ec2.availability_zone
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.ec2.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.ec2.public_dns
}

output "instance_ssh_username" {
  description = "Username for SSH connection"
  value       = "ec2-user"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.ec2.public_dns}"
}

output "data_volume_id" {
  description = "ID of the data EBS volume"
  value       = aws_ebs_volume.data_volume.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ec2_sg.id
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.ec2_role.name
}

output "backup_vault_name" {
  description = "Name of the backup vault"
  value       = var.enable_daily_backup ? aws_backup_vault.main[0].name : null
}

output "backup_plan_id" {
  description = "ID of the backup plan"
  value       = var.enable_daily_backup ? aws_backup_plan.daily_backup[0].id : null
}
