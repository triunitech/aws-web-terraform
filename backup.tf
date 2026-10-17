# ----------------------------------------------------------------------
# AWS Backup: RDS の日次バックアップ (保持 35 日)
# RDS 自動バックアップ (7 日) とは別に、独立した保管庫に長期保持します。
# ----------------------------------------------------------------------

resource "aws_backup_vault" "main" {
  name = "${local.name_prefix}-vault"

  tags = {
    Name = "${local.name_prefix}-vault"
  }
}

resource "aws_backup_plan" "daily" {
  name = "${local.name_prefix}-daily"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.backup_schedule_cron
    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after = var.backup_retention_days
    }
  }

  tags = {
    Name = "${local.name_prefix}-daily"
  }
}

# ---- IAM: AWS Backup サービスロール ---------------------------------------

data "aws_iam_policy_document" "backup_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup" {
  name               = "${local.name_prefix}-backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role.json
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_restores" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_selection" "rds" {
  name         = "${local.name_prefix}-rds"
  plan_id      = aws_backup_plan.daily.id
  iam_role_arn = aws_iam_role.backup.arn

  resources = [aws_db_instance.main.arn]
}
