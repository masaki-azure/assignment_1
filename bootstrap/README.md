# bootstrap

Terraform Backend 用リソースを初回のみ作成する。
本ディレクトリは CI/CD 対象外とし、

初回のみ手動実行する。

作成対象
- dev環境
  - リソースグループ: rg-health-dev
    - ストレージアカウント: sthealthtfstatedev
      - ストレージコンテナ: tfstate
- prod環境
  - リソースグループ: rg-health-prod
    - ストレージアカウント: sthealthtfstateprod
      - ストレージコンテナ: tfstate

## 実行方法

```bash
cd bootstrap
az login
terraform init
terraform plan
terraform apply
```

## 補足

bootstrap は Terraform Backend 自体を作成するため、
local backend を利用する。
