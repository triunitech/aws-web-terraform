# ----------------------------------------------------------------------
# 基本設定
# ----------------------------------------------------------------------

variable "project_name" {
  description = "プロジェクト名。リソース名のプレフィックスおよびタグに使用します。"
  type        = string
  default     = "smallweb"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.project_name))
    error_message = "project_name は英小文字で始まり、英小文字・数字・ハイフンのみ、2〜21 文字で指定してください。"
  }
}

variable "environment" {
  description = "環境名（dev / stg / prod など）。"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "デプロイ先の AWS リージョン。"
  type        = string
  default     = "ap-northeast-1"
}

variable "additional_tags" {
  description = "全リソースに追加で付与するタグ。"
  type        = map(string)
  default     = {}
}

# ----------------------------------------------------------------------
# ネットワーク
# ----------------------------------------------------------------------

variable "vpc_cidr" {
  description = "VPC の CIDR ブロック。"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "パブリックサブネットの CIDR（2 AZ 分）。"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "public_subnet_cidrs は 2 つ指定してください。"
  }
}

variable "private_subnet_cidrs" {
  description = "プライベートサブネットの CIDR（2 AZ 分）。"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "private_subnet_cidrs は 2 つ指定してください。"
  }
}

variable "enable_nat_gateway" {
  description = "NAT Gateway を作成するか。false の場合はプライベートサブネットからのインターネット向け通信ができません（代わりに SSM 用 VPC エンドポイントを作成します）。"
  type        = bool
  default     = true
}

# ----------------------------------------------------------------------
# ALB / 証明書
# ----------------------------------------------------------------------

variable "acm_certificate_arn" {
  description = "ALB の HTTPS リスナーに設定する ACM 証明書の ARN（同一リージョンで発行済みのもの）。"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:acm:", var.acm_certificate_arn))
    error_message = "acm_certificate_arn は arn:aws:acm: で始まる ARN を指定してください。"
  }
}

variable "alb_allowed_cidrs" {
  description = "ALB への HTTP/HTTPS アクセスを許可する CIDR の一覧。"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_deletion_protection" {
  description = "ALB の削除保護を有効にするか。本番環境では true を推奨します。"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "ターゲットグループのヘルスチェックパス。"
  type        = string
  default     = "/"
}

# ----------------------------------------------------------------------
# EC2 / Auto Scaling
# ----------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 インスタンスタイプ。"
  type        = string
  default     = "t3.small"
}

variable "asg_min_size" {
  description = "Auto Scaling グループの最小台数。"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Auto Scaling グループの最大台数。"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Auto Scaling グループの希望台数。"
  type        = number
  default     = 2
}

variable "root_volume_size" {
  description = "EC2 ルートボリュームのサイズ (GiB)。"
  type        = number
  default     = 20
}

variable "cpu_target_utilization" {
  description = "ターゲット追跡スケーリングの目標 CPU 使用率 (%)。"
  type        = number
  default     = 60
}

# ----------------------------------------------------------------------
# RDS (MySQL)
# ----------------------------------------------------------------------

variable "db_engine_version" {
  description = "RDS MySQL のエンジンバージョン。"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "RDS インスタンスクラス。"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "初期作成するデータベース名。"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "RDS マスターユーザー名。パスワードは Secrets Manager で自動管理されます。"
  type        = string
  default     = "dbadmin"
}

variable "db_allocated_storage" {
  description = "RDS の初期ストレージサイズ (GiB)。"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "RDS ストレージ自動拡張の上限 (GiB)。"
  type        = number
  default     = 100
}

variable "db_multi_az" {
  description = "RDS をマルチ AZ 構成にするか。"
  type        = bool
  default     = false
}

variable "db_deletion_protection" {
  description = "RDS の削除保護を有効にするか。本番環境では true を推奨します。"
  type        = bool
  default     = true
}

variable "db_skip_final_snapshot" {
  description = "RDS 削除時に最終スナップショットをスキップするか。本番環境では false を推奨します。"
  type        = bool
  default     = false
}

variable "db_snapshot_identifier" {
  description = "復旧時に使用する RDS スナップショット ID または ARN。空文字の場合は新規作成します。指定するとインスタンスが置き換わるため、運用手順書を参照してください。"
  type        = string
  default     = ""
}

variable "db_backup_retention_days" {
  description = "RDS 自動バックアップの保持日数。"
  type        = number
  default     = 7
}

# ----------------------------------------------------------------------
# 監視 / 通知
# ----------------------------------------------------------------------

variable "alarm_email" {
  description = "CloudWatch アラームの通知先メールアドレス。空文字の場合はサブスクリプションを作成しません。"
  type        = string
  default     = ""
}

variable "ec2_cpu_alarm_threshold" {
  description = "EC2 (ASG 平均) の CPU 使用率アラームしきい値 (%)。"
  type        = number
  default     = 80
}

variable "rds_cpu_alarm_threshold" {
  description = "RDS の CPU 使用率アラームしきい値 (%)。"
  type        = number
  default     = 80
}

variable "rds_free_storage_alarm_threshold_bytes" {
  description = "RDS 空きストレージのアラームしきい値 (バイト)。既定は 2 GiB。"
  type        = number
  default     = 2147483648
}

variable "rds_connections_alarm_threshold" {
  description = "RDS 同時接続数のアラームしきい値。"
  type        = number
  default     = 50
}

# ----------------------------------------------------------------------
# AWS Backup
# ----------------------------------------------------------------------

variable "backup_retention_days" {
  description = "AWS Backup の復旧ポイント保持日数。"
  type        = number
  default     = 35
}

variable "backup_schedule_cron" {
  description = "AWS Backup の実行スケジュール (UTC, cron 形式)。既定は毎日 18:00 UTC = JST 03:00。"
  type        = string
  default     = "cron(0 18 * * ? *)"
}
