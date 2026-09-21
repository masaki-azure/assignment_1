# 健康管理アプリ インフラ基盤（課題①）

健康管理のための Web アプリケーションに必要なインフラを Terraform で設計・実装。
Cloud Provider は Azure を採用。

---

## 1. 前提条件

| 項目 | 前提 |
|---|---|
| 想定トラフィック | 個人〜小規模チーム向けの健康管理アプリを想定。急激なスパイクは想定しない。 |
| 冗長構成 | prod のみリージョン内ゾーン冗長。マルチリージョン DR は本課題スコープ外（下記「3.4 非採用としたもの」参照） |
| データの機微性 | 体重・食事記録等の健康情報を扱うため、DB は要配慮情報に準じた扱いとする。 |
| デプロイ | 実際のデプロイは行わない。Azure環境を用意していない前提のため、`terraform plan`（実 API 疎通が必要）までは保証せず、`terraform fmt` / `terraform validate` / `tflint` / `tfsec` が通り、静的に構成の妥当性が評価できる状態。 |
| 画像配信経路 | 食事写真・記事画像等は Storage Account に格納するが、クライアントから Storage Account へ直接アクセスさせず、必ず Container Apps経由で配信する。Storage Account へのアクセスは Container Apps の Managed Identity のみに限定する |

---

## 2. アーキテクチャ概要

```
利用者
  ↓
Azure Front Door + WAF
  ↓
Azure Container Apps（Consumption Plan / 外部 Ingress）
  ↓ Private Endpoint 経由
PostgreSQL Flexible Server（Public Network Access 無効）

監視: Application Insights / Log Analytics Workspace
認証・シークレット: Managed Identity / Key Vault
画像等: Storage Account
```

インフラ構成図は `docs/InfrastructureArchitectureDiagram.svg`を参照。

### Figma のデザインから読み取った要件との対応

| 画面 | 読み取れる要素 | 対応するリソース |
|---|---|---|
| top myPage | 食事写真グリッド、推移グラフ | Storage Account（画像）、PostgreSQL（時系列レコード） |
| myRecord | 記録カード、数値テーブル | PostgreSQL（記録データ） |
| Column | 記事一覧（画像＋テキスト） | Storage Account（記事画像）、PostgreSQL（記事メタデータ） |
| 全画面共通 | ユーザーアバター表示 | 認証（Managed Identity 経由でのアプリ・DB 接続） |

---

## 3. 設計判断（採用・非採用の理由）

### 3.1 実行基盤：Container Apps

- 想定トラフィック（前提条件参照）に対して、常時起動の App Service Plan よりリクエスト駆動でコスト効率が良い
- 将来的なスケールアウト、複数コンテナ構成への拡張が説明しやすい

### 3.2 PostgreSQL：Private Endpoint を採用

- 健康記録という要配慮情報を扱うため、DB については外部到達経路そのものをなくす方針とした
- 上記に伴い、DB の Private Endpoint 配置に必要な最小限の VNet（`subnet-containerapps` と `subnet-private-endpoint` の 2 サブネットのみ）を用意した
- Public Network Access は無効化し、TLS を必須とする

### 3.3 Storage Account / Key Vault：Public のまま採用

- いずれも Container Apps からのみアクセスされ、閉域化の運用コストに見合う要求が現時点でない
- **Storage Account**：食事写真・記事画像等を格納する。クライアント（ブラウザ）が直接 Storage Account にアクセスすることは想定せず、必ず Container Apps 経由で配信する設計とする。アクセスキーは無効化し、Container Apps の Managed Identity 経由のみでアクセスを許可する
- **Key Vault**：RBAC 認可 + Managed Identity 経由のみでアクセス。Container Apps（Consumption プラン）は Egress IP が動的なため、IP ベースの Firewall 制御は機能しない。そのため RBAC 認可・Managed Identity のみでアクセスを制御する

### 3.4 非採用としたもの

| 項目 | 非採用の理由 |
|---|---|
| Storage Account / Key Vault への Private Endpoint | 現要件では Public + アクセス制御（キー無効化・RBAC）で要件を満たせる。IPベースのFirewallは、Key VaultについてはContainer Appsの Egress IP が動的なため採用していない。将来的なセキュリティ強化施策として、Private Endpoint への移行を想定した設計（VNet・サブネットの余地）は残している |
| Azure Firewall | 送信（Egress）制御を厳格化する要件が現時点でないため見送り。WAF（Front Door 側）で十分な入口対策とした |
| マルチリージョン DR | 課題スコープに対して過剰。ゾーン冗長までで単一リージョン内の AZ 障害を吸収する方針とした |
| Front Door からの Storage Account 直接配信（マルチオリジン） | 現状は画像もアプリ（Container Apps）経由で配信する設計とした。トラフィック増加時の最適化候補として、将来的に Front Door のマルチオリジン構成を検討する余地は残す |

---

## 4. 環境分離

- 同一サブスクリプション内で、リソースグループにより分離
  - `rg-health-dev`
  - `rg-health-prod`
- 状態ファイル（tfstate）も環境ごとに分離し、Storage Account のコンテナを分ける（`environments/dev`, `environments/prod` を参照）

### 環境ごとの差分

| 項目 | dev | prod |
|---|---|---|
| Container Apps 環境 | 単一ゾーン | Zone Redundant |
| PostgreSQL | HA なし | Zone Redundant HA |
| Storage Account | LRS | ZRS |
| Front Door | Standard | Premium（WAF マネージドルール適用） |

---

## 5. 命名規則

`{resource-prefix}-{workload}-{env}[-{seq}]`

例：
- リソースグループ：`rg-health-prod`
- Container Apps 環境：`cae-health-prod`
- PostgreSQL：`psql-health-prod`
- Key Vault：`kv-health-prod`（グローバル一意制約があるため、必要に応じて suffix を付与）
- Storage Account：`sthealthprod`

---

## 6. タグ規則

すべてのリソースに以下のタグを付与する。

| タグキー | 例 | 用途 |
|---|---|---|
| `environment` | `dev` / `prod` | 環境識別、コスト集計 |
| `project` | `health-app` | プロジェクト単位のコスト集計 |
| `managed-by` | `terraform` | 手動変更の抑止・追跡 |
| `owner` | チームまたは担当者名 | 問い合わせ先の明確化 |

---

## 7. セキュリティ既定値

- DB は Private Endpoint 経由のみ、Public Network Access 無効
- Storage Account はアクセスキー無効化、Managed Identity 経由のみ
- Key Vault は RBAC 認可、Managed Identity 経由のみ。Container Apps の Egress IP が動的なため、IP Firewall による制限は行わない
- すべての通信で TLS 1.2 以上を必須とする
- リソース間の認証は極力 Managed Identity を用い、接続文字列やパスワードの直接受け渡しを避ける

## 8. Secret の扱い

- DB 管理者パスワード等の Secret は Terraform の変数に直書きしない
- CI/CD（GitHub Actions）からは GitHub Secrets 経由で Azure に対して OIDC 連携（Federated Credential）で認証し、長期間有効なクライアントシークレットを持たない運用とする
- アプリケーションが必要とする Secret（DB 接続情報等）は Key Vault に格納し、Container Apps からは Managed Identity 経由で参照する

## 9. リリース手順（想定）

1. Pull Request 作成時：`terraform fmt -check`, `terraform validate`, lint（tflint）, security scan（tfsec 等）を GitHub Actions で自動実行
2. dev 環境：PR マージ後に自動で `terraform plan` → 承認不要で `apply`
3. prod 環境：dev 環境での動作確認後、手動承認ステップ（GitHub Environments の protection rule）を経て `apply`
4. 変更内容は PR の diff と `terraform plan` の出力で事前にレビューする

---

## 10. 未実装部分・TODO・見積り

想定作業時間（7 時間）内で「評価可能な状態」を優先し、以下は未実装またはスコープ外とした。

| 項目 | 状態 | 見積り（追加実装した場合） |
|---|---|---|
| 実際の Azure 環境への apply / 動作確認 | 未実施 | - |
| Storage Account / Key Vault への Private Endpoint 化 | 未実装（3.4 節参照） | 半日程度（Private DNS Zone 追加含む） |
| Front Door マルチオリジン構成（Storage 直配信） | 未実装（3.4 節参照） | 半日程度 |
| Container Apps への直接アクセス防止（Front Door バイパス対策） | 未実装。Ingress設定での送信元制限、または X-Azure-FDID ヘッダー検証ルールの追加を想定 | 1〜2時間程度 |
| Azure Monitor アラートルール（しきい値監視） | 未実装 | 数時間 |
| バックアップ・リストア手順の具体化（PITR の保持期間等） | 前提のみ記載、詳細未検討 | 数時間 |

---

## 11. ディレクトリ構成

```
healthapp-infra/
├── docs/
│   └── InfrastructureArchitectureDiagram.svg          # インフラ構成図
├── modules/
│   ├── network/                  # VNet, Subnet, Private DNS Zone
│   ├── app/                      # Container Apps 環境・アプリ
│   ├── data/                     # PostgreSQL Flexible Server, Private Endpoint
│   ├── edge/                     # Front Door, WAF
│   ├── storage/                  # Storage Account
│   ├── security/                 # Key Vault, Managed Identity, RBAC 割り当て
│   └── monitoring/               # Log Analytics, Application Insights
├── environments/
│   ├── dev/
│   └── prod/
├── bootstrap/                    # Terraform実行に必要な土台（リソースグループ、tfstate保存用Storage Account）を
│                                 # 初回のみ手動で作成するための補助コード。通常のCI/CDパイプラインの対象外（詳細は bootstrap/README.md）
├── .github/workflows/
│   ├── terraform-ci.yml
│   ├── terraform-plan.yml
│   ├── terraform-apply-dev.yml
│   └── terraform-apply-prod.yml
├── .tflint.hcl                   # tflint設定
└── README.md
```
