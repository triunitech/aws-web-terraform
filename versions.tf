terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ------------------------------------------------------------------
  # リモートバックエンド（任意）
  # チームで state を共有する場合は、以下のコメントを外して
  # S3 バケットと DynamoDB テーブルを事前に作成してください。
  # ------------------------------------------------------------------
  # backend "s3" {
  #   bucket         = "my-company-terraform-state"
  #   key            = "small-web/prod/terraform.tfstate"
  #   region         = "ap-northeast-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
