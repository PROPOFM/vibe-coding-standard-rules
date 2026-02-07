# ルール整備状況

`docs/reference/existing-ruls.md`に記載されているルールの、本リポジトリへの反映状況をまとめます。

## 📊 現在の状況

### ✅ 作成済み（一部反映）

以下のルールは、Claude Code用の設定として一部反映されています：

**Claude Code Rules** (`claude-code/rules/`):
- ✅ `security.md` - セキュリティチェック（既存ルールから一部反映）
- ✅ `testing.md` - TDD、80%カバレッジ要件（既存ルールから一部反映）
- ✅ `coding-style.md` - コーディングスタイル（既存ルールから一部反映）
- ✅ `git-workflow.md` - Gitワークフロー（既存ルールから一部反映）
- ✅ `agents.md` - エージェント使用ガイドライン（新規作成）
- ✅ `performance.md` - パフォーマンス・コンテキスト管理（新規作成）

**Claude Code Agents** (`claude-code/agents/`):
- ✅ `planner.md` - 計画立案エージェント（新規作成）
- ✅ `code-reviewer.md` - コードレビューエージェント（新規作成）
- ✅ `tdd-guide.md` - TDDガイドエージェント（既存ルールから反映）

**Claude Code Skills** (`claude-code/skills/`):
- ✅ `tdd-workflow/SKILL.md` - TDDワークフロー（既存ルールから反映）

**Cursor Skills** (`cursor/skills/`):
- ✅ `tdd-workflow/SKILL.md` - TDDワークフロー（既存ルールから反映）

### ⚠️ 未作成（整備が必要）

以下のルールは、`existing-ruls.md`から汎用化して追加する必要があります：

#### **コアルール** (`core/`)

**高優先度（必須）**:
- ❌ `base-prompt.md` - AIの口調や思考プロセス
- ❌ `coding-style.md` - 命名規則、ディレクトリ構造、推奨ライブラリ
- ❌ `architecture.md` - アーキテクチャ原則（モノレポ、共通基盤の活用、依存関係管理）
- ❌ `test-standard.md` - テストコードの書き方、網羅性の基準、TDD原則（詳細版）
- ❌ `security.md` - セキュリティ対策、秘密情報の扱い（詳細版）
- ❌ `error-handling.md` - エラーハンドリングの原則と実装パターン
- ❌ `logging.md` - ログ管理の原則と実装パターン
- ❌ `configuration.md` - 設定管理の原則（環境変数、設定ファイル等）

**中優先度**:
- ❌ `code-review.md` - コードレビューの観点とチェックリスト
- ❌ `development-process.md` - 開発プロセス（修正作業の実施手順等）
- ❌ `documentation.md` - ドキュメント作成のベストプラクティス

#### **言語固有ルール** (`languages/`)

- ❌ `typescript.md` - TypeScript固有のルール（厳密な型チェック、環境変数アクセス等）

#### **クラウドサービス固有ルール** (`cloud-services/`)

- ❌ `bigquery.md` - BigQueryコスト最適化ガイドライン（既存ルールに詳細な内容あり）
- ❌ `supabase.md` - Supabase操作ガイドライン（既存ルールに詳細な内容あり）
- ❌ `gcp.md` - Google Cloud Platform固有のルール（Cloud Build、Cloud Run等）

## 📋 既存ルールからの抽出マッピング

### `existing-ruls.md`の主要セクション → 対応するコアルールファイル

| 既存ルールのセクション | 対応するコアルールファイル | 優先度 | 状況 |
|---------------------|----------------------|--------|------|
| **アーキテクチャ原則** | `core/architecture.md` | 高 | ❌ 未作成 |
| - モノレポ構造 | `core/architecture.md` | 高 | ❌ 未作成 |
| - 共通基盤の活用 | `core/architecture.md` | 高 | ❌ 未作成 |
| - 依存関係管理 | `core/architecture.md` | 高 | ❌ 未作成 |
| **コーディング規約** | `core/coding-style.md` | 高 | ❌ 未作成 |
| - TypeScript | `languages/typescript.md` | 高 | ❌ 未作成 |
| - 設定管理 | `core/configuration.md` | 高 | ❌ 未作成 |
| - ログ管理 | `core/logging.md` | 高 | ❌ 未作成 |
| - エラーハンドリング | `core/error-handling.md` | 高 | ❌ 未作成 |
| **開発フロー** | `core/development-process.md` | 中 | ❌ 未作成 |
| - TDD原則 | `core/test-standard.md` | 高 | ⚠️ 一部反映（skills/agents） |
| - 修正作業の実施手順 | `core/development-process.md` | 中 | ❌ 未作成 |
| **テスト戦略** | `core/test-standard.md` | 高 | ⚠️ 一部反映（claude-code/rules/testing.md） |
| **セキュリティ** | `core/security.md` | 高 | ⚠️ 一部反映（claude-code/rules/security.md） |
| **デプロイメント** | `cloud-services/gcp.md` | 中 | ❌ 未作成 |
| **BigQueryコスト最適化** | `cloud-services/bigquery.md` | 高 | ❌ 未作成 |
| **Supabase操作** | `cloud-services/supabase.md` | 高 | ❌ 未作成 |
| **ドキュメント** | `core/documentation.md` | 中 | ❌ 未作成 |
| **品質管理** | `core/code-review.md` | 中 | ❌ 未作成 |

## 🎯 整備の優先順位

### フェーズ1: 高優先度（必須）

1. **`core/architecture.md`**
   - モノレポ構造の原則
   - 共通基盤の活用（判断基準、判断フロー、実装ルール）
   - 依存関係管理とビルド順序の原則
   - データベース開発アプローチ（4層環境構成、開発フロー、管理ルール）

2. **`core/coding-style.md`**
   - 命名規則
   - ディレクトリ構造
   - 推奨ライブラリ
   - ファイル構造の原則

3. **`core/test-standard.md`**（詳細版）
   - TDD原則（RED → GREEN → REFACTOR）
   - テストカバレッジ要件（80%以上）
   - テスト戦略の根本原則
   - テストスクリプト管理

4. **`core/security.md`**（詳細版）
   - 環境変数の管理
   - API認証
   - データベースセキュリティ
   - OWASP Top 10対応

5. **`core/error-handling.md`**
   - エラーハンドリングの原則
   - カスタムエラーの実装パターン
   - エラーレベルとステータスコード

6. **`core/logging.md`**
   - ログ管理の原則
   - 構造化ログ（JSON形式）
   - ログレベルの使い分け

7. **`core/configuration.md`**
   - 設定管理の原則
   - 環境変数の管理
   - 設定ファイルの一元管理

8. **`languages/typescript.md`**
   - TypeScript固有のルール
   - 厳密な型チェック
   - 環境変数アクセス方法

9. **`cloud-services/bigquery.md`**
   - BigQueryコスト最適化ガイドライン
   - パーティション条件の必須化
   - バッチ処理の原則
   - 高コストエンドポイントの保護

10. **`cloud-services/supabase.md`**
    - Supabase操作ガイドライン
    - 環境管理
    - マイグレーション管理

### フェーズ2: 中優先度

11. **`core/code-review.md`**
    - コードレビューの観点
    - チェックリスト

12. **`core/development-process.md`**
    - 修正作業の実施手順
    - 原因調査と分析
    - 修正方針の提示

13. **`core/documentation.md`**
    - ドキュメント作成のベストプラクティス
    - Mermaid記法の活用

14. **`cloud-services/gcp.md`**
    - GCP環境整備
    - Cloud Build設定
    - Cloud Run対応

### フェーズ3: 低優先度（オプション）

15. **`frameworks/nextjs.md`**（必要に応じて）
16. **その他の言語・フレームワーク固有ルール**

## 📝 整備方法

### ステップ1: 既存ルールの分析

`docs/reference/existing-ruls.md`を読み、汎用化可能な部分を特定します。

### ステップ2: プロジェクト固有部分の除去

- 特定のプロジェクト名（`[PROJECT_NAME]`）を削除
- 特定のモジュール名（`0000_common`、`0010_[module-name]`等）を汎用化
- 特定の技術スタックに依存する部分を分離

### ステップ3: 共通ルールとして再構成

- 推奨される構造に従って再構成
- 具体例を含める
- 参考リンクを追加

### ステップ4: レビュー・マージ

- Pull Requestを作成
- レビュー後、マージ

## 🔄 整備状況の更新

このファイルは、ルールの整備が進むにつれて更新してください。

**最終更新**: 2025-02-07
**次回更新予定**: コアルールファイル作成時

