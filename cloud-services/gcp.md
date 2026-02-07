# GCP Rules

GCP環境整備、Cloud Build、Cloud Run対応に関するルールです。

## 概要

このルールは、GCP環境整備の原則、Cloud Build設定、Cloud Runサービス分割、環境分離戦略を定義します。スケーラブルで保守性の高いGCP環境を構築するための基本原則です。

## 基本原則

### 1. モジュール別Cloud Runサービス分割

**基本方針: モジュールごとに独立したCloud Runサービスをデプロイ**

**分割単位**:
- **共通基盤**: 共通基盤ライブラリ（Cloud Runサービス対象外）
- **モジュール1**: `[PROJECT_NAME]-[module-name]-service`
- **モジュール2**: `[PROJECT_NAME]-[module-name]-service`
- **モジュール3**: `[PROJECT_NAME]-[module-name]-service`

**分割のメリット**:
- **独立スケーリング**: モジュール単位でCPU/メモリを最適化
- **独立デプロイ**: モジュール単位でデプロイ・ロールバック可能
- **障害分離**: 1つのモジュールの障害が他に影響しない
- **リソース最適化**: モジュールごとに必要なリソースを設定

### 2. 環境分離戦略

**GCPプロジェクト単位での環境分離**:

| 環境 | GCPプロジェクト | 目的 | モジュール数 |
|------|----------------|------|-------------|
| **開発環境** | `[PROJECT_NAME]-dev` | 開発・テスト用 | 全モジュール |
| **PreProd環境** | `[PROJECT_NAME]-preprod` | 本番前検証用 | 全モジュール |
| **本番環境** | `[PROJECT_NAME]-prod` | 本番運用用 | 全モジュール |

**環境分離のメリット**:
- **完全分離**: IAM、ネットワーク、クォータ、請求の完全分離
- **安全性**: 開発環境のミスが本番環境に影響しない
- **権限管理**: 環境ごとに異なるアクセス権限を設定可能

### 3. Cloud Build設定方針

**モジュール別Cloud Build設定**:

**基本構造**:
```
cloudbuild/
├── common/
│   └── cloudbuild.yaml          # 共通基盤ビルド
├── module-1/
│   └── cloudbuild.yaml         # モジュール1サービスビルド
├── module-2/
│   └── cloudbuild.yaml         # モジュール2サービスビルド
└── module-3/
    └── cloudbuild.yaml          # モジュール3サービスビルド
```

**Cloud Buildの役割**:
- **ソースコード取得**: リポジトリからコードを取得
- **コンテナイメージビルド**: Dockerfileを使用してイメージ作成
- **テスト実行**: ユニットテスト・統合テスト実行
- **Artifact Registryプッシュ**: ビルド済みイメージの保存
- **Cloud Runデプロイ**: 新しいイメージのデプロイ

### 4. Cloud Run設定方針

**モジュール別Cloud Runサービス設定**:

**サービス命名規則**:
- **開発環境**: `[PROJECT_NAME]-dev-[module-name]`
- **PreProd環境**: `[PROJECT_NAME]-preprod-[module-name]`
- **本番環境**: `[PROJECT_NAME]-prod-[module-name]`

**リソース設定**:
- **CPU**: モジュールごとに最適化（0.5-2.0 vCPU）
- **メモリ**: モジュールごとに最適化（512MB-4GB）
- **最大インスタンス数**: モジュールごとに設定
- **最小インスタンス数**: 0（コスト最適化）

### 5. モジュール間連携戦略

**統合フローの実装方針**:

**Option 1: Cloud Workflows（推奨）**
- 複数Cloud Runサービスを順次・並列実行
- 複雑なワークフローの定義が可能
- エラーハンドリングとリトライ機能

**Option 2: Pub/Sub + Event-driven**
- 非同期・疎結合な連携
- モジュール間の依存関係を最小化
- スケーラビリティの向上

**Option 3: HTTP API連携**
- 直接的なHTTP呼び出し
- シンプルな実装
- デバッグが容易

### 6. デプロイメント戦略

**段階的デプロイメント**:

**Step 1: 開発環境**
```bash
# 開発環境へのデプロイ
gcloud builds submit --config module-1/cloudbuild.yaml --project [PROJECT_NAME]-dev
gcloud builds submit --config module-2/cloudbuild.yaml --project [PROJECT_NAME]-dev
```

**Step 2: PreProd環境**
```bash
# PreProd環境へのデプロイ
gcloud builds submit --config module-1/cloudbuild.yaml --project [PROJECT_NAME]-preprod
gcloud builds submit --config module-2/cloudbuild.yaml --project [PROJECT_NAME]-preprod
```

**Step 3: 本番環境**
```bash
# 本番環境へのデプロイ
gcloud builds submit --config module-1/cloudbuild.yaml --project [PROJECT_NAME]-prod
gcloud builds submit --config module-2/cloudbuild.yaml --project [PROJECT_NAME]-prod
```

### 7. 監視・ログ戦略

**モジュール別監視**:
- **Cloud Logging**: モジュールごとのログ分離
- **Cloud Monitoring**: モジュールごとのメトリクス監視
- **アラート設定**: モジュールごとのアラート設定

**統合監視**:
- **統合フローの監視**: モジュール間連携の監視
- **エンドツーエンド監視**: 完全なフローの監視
- **パフォーマンス監視**: レスポンス時間・スループット監視

### 8. セキュリティ戦略

**環境別セキュリティ**:
- **IAM権限**: 環境ごとに異なるアクセス権限
- **ネットワーク**: 環境ごとのネットワーク分離
- **シークレット管理**: 環境ごとのシークレット管理

**モジュール別セキュリティ**:
- **API認証**: モジュール間の認証・認可
- **データ暗号化**: モジュール間のデータ暗号化
- **監査ログ**: モジュールごとの監査ログ

## 具体的な指針

### Cloud Build設定の実装

**cloudbuild.yamlの例**:
```yaml
steps:
  # 共通基盤のビルド
  - name: 'gcr.io/cloud-builders/npm'
    args: ['run', 'build']
    dir: 'common'
  
  # モジュールのビルド
  - name: 'gcr.io/cloud-builders/npm'
    args: ['run', 'build']
    dir: 'module-1'
  
  # コンテナイメージのビルド
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/module-1', './module-1']
  
  # Artifact Registryへのプッシュ
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/module-1']
  
  # Cloud Runへのデプロイ
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'run'
      - 'deploy'
      - '[PROJECT_NAME]-dev-module-1'
      - '--image'
      - 'gcr.io/$PROJECT_ID/module-1'
      - '--region'
      - 'asia-northeast1'
```

### Cloud Run設定の実装

**リソース設定の例**:
```yaml
# cloudbuild.yaml内で設定
- name: 'gcr.io/cloud-builders/gcloud'
  args:
    - 'run'
    - 'deploy'
    - '[PROJECT_NAME]-dev-module-1'
    - '--image'
    - 'gcr.io/$PROJECT_ID/module-1'
    - '--region'
    - 'asia-northeast1'
    - '--cpu'
    - '1'
    - '--memory'
    - '1Gi'
    - '--max-instances'
    - '10'
    - '--min-instances'
    - '0'
```

## 禁止事項

**❌ やってはいけないこと**:
- 全モジュールを1つのCloud Runサービスにデプロイ
- 環境を分離せずに運用
- ハードコードされた設定値
- セキュリティ設定の省略

**✅ 必ずやること**:
- モジュールごとに独立したCloud Runサービスをデプロイ
- 環境ごとにGCPプロジェクトを分離
- 設定は環境変数で管理
- セキュリティ設定を適切に実装

## 例外・特別なケース

### レガシーシステムへの対応

既存のシステムに導入する場合:
- 段階的なモジュール分割
- 既存システムへの影響を最小化
- 移行計画を立てる

## 参考リンク

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [GCP Best Practices](https://cloud.google.com/docs/enterprise/best-practices)

