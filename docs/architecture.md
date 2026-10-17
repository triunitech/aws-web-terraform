# 構成図 — AWS 小規模Webシステム構成テンプレート

> 自社制作のデモです（受託案件ではありません）。

## 全体構成

```mermaid
flowchart TB
    User((利用者)) -->|HTTPS 443 / HTTP 80 → 301| ALB

    subgraph VPC["VPC 10.0.0.0/16（ap-northeast-1）"]
        direction TB

        subgraph Public["パブリックサブネット（2 AZ）"]
            ALB["ALB<br/>ACM 証明書 / TLS 1.3"]
            NAT["NAT Gateway<br/>（任意・1 台）"]
        end

        subgraph Private["プライベートサブネット（2 AZ）"]
            ASG["Auto Scaling グループ<br/>EC2 t3.small × 2〜4<br/>Amazon Linux 2023 / nginx"]
            RDS[("RDS for MySQL<br/>db.t3.micro<br/>マルチ AZ は変数")]
        end

        VPCE["VPC エンドポイント<br/>S3（常時）/ SSM（NAT なし時）"]
    end

    ALB -->|HTTP 80<br/>SG で ALB のみ許可| ASG
    ASG -->|3306<br/>SG で EC2 のみ許可| RDS
    ASG -.->|外向き 443| NAT
    ASG -.-> VPCE

    S3["S3 バケット<br/>アップロード / バックアップ<br/>バージョニング・SSE・公開遮断"]
    SM["Secrets Manager<br/>RDS マスター認証情報"]
    SSM["SSM Session Manager<br/>（SSH 鍵なし）"]
    CW["CloudWatch アラーム<br/>ALB 5xx / EC2 CPU / RDS"]
    SNS["SNS → メール通知"]
    BK["AWS Backup<br/>日次・35 日保持"]

    ASG -->|IAM ロール| S3
    ASG -->|IAM ロール| SM
    SSM -.-> ASG
    ALB -.-> CW
    ASG -.-> CW
    RDS -.-> CW
    CW --> SNS
    RDS -.-> BK
```

## 通信経路とセキュリティグループ

```mermaid
flowchart LR
    Internet["インターネット<br/>alb_allowed_cidrs"] -->|80, 443| ALBSG["alb-sg"]
    ALBSG -->|80 のみ| APPSG["app-sg"]
    APPSG -->|3306 のみ| DBSG["db-sg"]
    APPSG -->|443 のみ（外向き）| Out["NAT / VPC エンドポイント"]
```

- `alb-sg`: 受信 80/443（許可 CIDR から）、送信は `app-sg` の 80 のみ
- `app-sg`: 受信は `alb-sg` からの 80 のみ、送信は 443（SSM、パッケージ取得、AWS API）と `db-sg` の 3306 のみ
- `db-sg`: 受信は `app-sg` からの 3306 のみ、送信なし

## バックアップ系統

```mermaid
flowchart LR
    RDS[("RDS for MySQL")]
    RDS -->|自動バックアップ<br/>7 日・ポイントインタイム| AB["RDS 自動バックアップ"]
    RDS -->|AWS Backup<br/>日次 JST 03:00・35 日| BV["Backup 保管庫"]
    S3["S3 アップロード"] -->|バージョニング<br/>旧版 90 日保持| S3V["旧バージョン"]
```

詳細は [README.md](../README.md) の「運用手順書」をご参照ください。
