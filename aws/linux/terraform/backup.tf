# Backup Plan (Daily snapshots)
resource "aws_backup_plan" "daily_backup" {
  count = var.enable_daily_backup ? 1 : 0

  name = "${var.project_name}-daily-backup"

  rule {
    rule_name         = "daily-backup-rule"
    target_vault_name = aws_backup_vault.main[0].name
    schedule          = "cron(0 5 * * ? *)" # Daily at 5 AM UTC

    lifecycle {
      delete_after = var.backup_retention_days
    }
  }

  tags = {
    Name = "${var.project_name}-backup-plan"
  }
}

resource "aws_backup_vault" "main" {
  count = var.enable_daily_backup ? 1 : 0

  name = "${var.project_name}-backup-vault"

  tags = {
    Name = "${var.project_name}-backup-vault"
  }
}

# Backup selection (assign resources to backup plan)
resource "aws_backup_selection" "backup_selection" {
  count = var.enable_daily_backup ? 1 : 0

  name         = "${var.project_name}-backup-selection"
  plan_id      = aws_backup_plan.daily_backup[0].id
  iam_role_arn = aws_iam_role.backup_role[0].arn

  resources = [
    aws_ebs_volume.data_volume.arn
  ]
}

# IAM Role for Backup
resource "aws_iam_role" "backup_role" {
  count = var.enable_daily_backup ? 1 : 0

  name = "${var.project_name}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-backup-role"
  }
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  count = var.enable_daily_backup ? 1 : 0

  role       = aws_iam_role.backup_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}
