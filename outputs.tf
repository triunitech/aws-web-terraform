output "alb_dns_name" {
  description = "ALB の DNS 名。Route 53 などでこの名前に ALIAS/CNAME を向けてください。"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB のホストゾーン ID (Route 53 ALIAS レコード用)。"
  value       = aws_lb.main.zone_id
}

output "vpc_id" {
  description = "VPC ID。"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "パブリックサブネット ID の一覧。"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "プライベートサブネット ID の一覧。"
  value       = aws_subnet.private[*].id
}

output "autoscaling_group_name" {
  description = "Auto Scaling グループ名。"
  value       = aws_autoscaling_group.app.name
}

output "rds_endpoint" {
  description = "RDS のエンドポイント (host:port)。"
  value       = aws_db_instance.main.endpoint
}

output "rds_master_user_secret_arn" {
  description = "RDS マスターユーザーの認証情報を格納する Secrets Manager シークレットの ARN。"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "uploads_bucket_name" {
  description = "アップロード / バックアップ用 S3 バケット名。"
  value       = aws_s3_bucket.uploads.bucket
}

output "sns_alarm_topic_arn" {
  description = "アラーム通知用 SNS トピックの ARN。"
  value       = aws_sns_topic.alarms.arn
}

output "backup_vault_name" {
  description = "AWS Backup の保管庫名。"
  value       = aws_backup_vault.main.name
}
