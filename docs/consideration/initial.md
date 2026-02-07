# **vibe-coding-standard-rules 運用・整備ガイド**

AIツール（Cursor / Claude Code）の指示（Rules）を複数のプロジェクトで共通化し、かつプロジェクト固有の事情にも柔軟に対応するための管理・運用方針です。

## **1\. 用語定義**

### **ラッパー (Wrapper) とは**

本書における「ラッパー」とは、AIツールが直接読み込む設定ファイル（`.cursorrules` や `.clauderules`）を指します。 これらは**実体（共通ルール）を包み込み、AIへの入り口（窓口）として機能させる**ため、ラッパーと呼びます。

* **役割**: プロジェクトルートに位置し、共通ディレクトリ（`.ai-rules/`）やプロジェクト固有ルール（`.rules/`）への参照（ポインタ）をAIに示します。
* **特徴**: ラッパー自体は最小限の記述に留め、実際のルールは別ファイルに分離することで保守性を向上させます。

### **その他の用語**

* **共通ルール** (`.ai-rules/`): 複数のプロジェクトで共有されるルール。サブモジュールとして管理。
* **プロジェクト固有ルール** (`.rules/`): 特定のプロジェクトのみに適用されるルール。プロジェクトリポジトリ内で管理。
* **コアルール** (`core/`): 言語やツールに依存しない、最も基本的なルール群。

## **2\. リポジトリ構成案（共通管理リポジトリ）**

共通ルールリポジトリ（`.ai-rules` として取り込まれる側）には、以下のファイルを管理します。

```
vibe-coding-standard-rules/
├── core/                           # 言語やツールに依存しない「共通の教科書」
│   ├── base-prompt.md              # AIの口調や思考プロセス（例：簡潔に答えて、等）
│   ├── coding-style.md             # 命名規則、ディレクトリ構造、推奨ライブラリ
│   ├── architecture.md             # アーキテクチャ原則（モノレポ、共通基盤の活用等）
│   ├── test-standard.md             # テストコードの書き方、網羅性の基準、TDD原則
│   ├── security.md                 # セキュリティ対策、秘密情報の扱い
│   ├── error-handling.md           # エラーハンドリングの原則と実装パターン
│   ├── logging.md                  # ログ管理の原則と実装パターン
│   ├── configuration.md            # 設定管理の原則（環境変数、設定ファイル等）
│   ├── code-review.md              # コードレビューの観点とチェックリスト
│   ├── development-process.md      # 開発プロセス（修正作業の実施手順等）
│   └── documentation.md            # ドキュメント作成のベストプラクティス
├── languages/                      # 言語固有のルール（オプション）
│   ├── typescript.md               # TypeScript固有のルール
│   ├── python.md                   # Python固有のルール
│   └── ...
├── frameworks/                     # フレームワーク固有のルール（オプション）
│   ├── nextjs.md                   # Next.js固有のルール
│   └── ...
├── cloud-services/                 # クラウドサービス固有のルール（オプション）
│   ├── gcp.md                      # Google Cloud Platform固有のルール
│   ├── bigquery.md                 # BigQueryコスト最適化ガイドライン
│   ├── supabase.md                 # Supabase操作ガイドライン
│   └── ...
├── claude-code/                    # Claude Code専用設定
│   ├── agents/                     # 専門エージェント（frontmatter形式）
│   │   ├── planner.md              # 機能実装の計画立案
│   │   ├── architect.md            # システム設計・アーキテクチャ決定
│   │   ├── tdd-guide.md            # テスト駆動開発のガイド
│   │   ├── code-reviewer.md        # コード品質・セキュリティレビュー
│   │   ├── security-reviewer.md    # 脆弱性分析（OWASP Top 10対応）
│   │   ├── build-error-resolver.md # ビルドエラー解決
│   │   └── ...
│   ├── skills/                     # ワークフロー定義とドメイン知識
│   │   ├── coding-standards.md     # 言語別ベストプラクティス
│   │   ├── backend-patterns.md     # API・データベース・キャッシュパターン
│   │   ├── frontend-patterns.md    # React・Next.jsパターン
│   │   ├── tdd-workflow/           # TDD手法の詳細定義
│   │   │   └── SKILL.md
│   │   └── ...
│   ├── commands/                   # スラッシュコマンド
│   │   ├── tdd.md                  # /tdd - テスト駆動開発ワークフロー
│   │   ├── plan.md                 # /plan - 実装計画の作成
│   │   ├── code-review.md          # /code-review - 品質レビュー
│   │   └── ...
│   ├── rules/                      # 常に従うルール（モジュラー分割）
│   │   ├── security.md             # 必須セキュリティチェック
│   │   ├── coding-style.md         # 不変性、ファイル構成
│   │   ├── testing.md              # TDD、80%カバレッジ要件
│   │   ├── git-workflow.md         # コミット形式、PR手順
│   │   ├── agents.md               # エージェントの使用タイミング
│   │   ├── performance.md          # モデル選択、コンテキスト管理
│   │   └── ...
│   ├── hooks/                      # トリガーベース自動化
│   │   ├── format-on-edit.json     # 編集後の自動フォーマット
│   │   ├── console-log-warning.json # console.log警告
│   │   └── ...
│   ├── mcp-configs/                # MCPサーバー設定（テンプレート）
│   │   ├── github.json             # GitHub MCP設定例
│   │   ├── supabase.json           # Supabase MCP設定例
│   │   └── ...
│   └── .clauderules.base           # Claude Code用のラッパーテンプレート
├── cursor/                         # Cursor専用設定
│   ├── skills/                     # Cursor Skills（SKILL.md形式）
│   │   ├── tdd-workflow/           # TDDワークフロースキル
│   │   │   ├── SKILL.md
│   │   │   └── scripts/
│   │   ├── code-review/            # コードレビュースキル
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   └── ...
│   └── .cursorrules.base           # Cursor用のラッパーテンプレート
├── scripts/
│   ├── setup-rules.sh              # リンク作成や初期設定を自動化するスクリプト
│   ├── validate-rules.sh           # ルールファイルの検証スクリプト
│   └── install-claude-code.sh      # Claude Code設定のインストールスクリプト
├── templates/                      # プロジェクト固有ルールのテンプレート
│   ├── project-specs.template.md   # project-specs.md のテンプレート
│   └── overrides.template.md       # overrides.md のテンプレート
├── CHANGELOG.md                    # ルールの変更履歴
└── README.md                       # リポジトリの説明と使用方法（このファイル）
```

**構成の説明**:
* `core/`: すべてのプロジェクトで共通して適用される基本ルール
* `languages/`, `frameworks/`: 必要に応じて参照する言語・フレームワーク固有のルール
* `cloud-services/`: クラウドサービス固有のルール（BigQuery、Supabase等）
* `claude-code/`: Claude Code専用の設定（agents, skills, commands, rules, hooks, mcp-configs）
* `cursor/`: Cursor専用の設定（skills）
* `templates/`: 新規プロジェクトで使用するテンプレート
* `CHANGELOG.md`: ルールの変更履歴を管理（非推奨化の通知など）

### **Claude CodeとCursorの機能対応**

#### **Claude Code対応機能**
* **agents/**: 専門エージェント（frontmatter形式で定義、必要最小限のツールを指定）
* **skills/**: ワークフロー定義（`~/.claude/skills/`または`.claude/skills/`に配置）
* **commands/**: スラッシュコマンド（`~/.claude/commands/`に配置、`/tdd`など）
* **rules/**: 常に従うルール（`~/.claude/rules/`に配置、モジュラーに分割）
* **hooks/**: トリガーベース自動化（`~/.claude/settings.json`に追加）
* **mcp-configs/**: MCPサーバー設定（`~/.claude.json`に追加、10個以下に抑える）

#### **Cursor対応機能**
* **skills/**: エージェントスキル（`.cursor/skills/`または`~/.cursor/skills/`に配置、SKILL.md形式）
* **.cursorrules**: ラッパーファイル（プロジェクトルートに配置）

### **推奨デフォルト設定**

#### **Claude Code推奨設定**
1. **MCPの有効化**: 10個以下に抑える（コンテキストウィンドウの縮小を防ぐ）
2. **TDD中心**: RED → GREEN → REFACTORサイクル、80%以上のカバレッジを必須
3. **エージェントのツール制限**: 必要最小限のツールのみ指定（5個程度が最適）
4. **hooksの活用**: 編集後の自動フォーマット、console.log警告など

#### **Cursor推奨設定**
1. **スキルの段階的読み込み**: 必要なときにだけリソースを読み込む
2. **プロジェクトレベルとユーザーレベルの使い分け**: プロジェクト固有は`.cursor/skills/`、共通は`~/.cursor/skills/`

### **既存ルールからの汎用ルール抽出プロセス**

既存プロジェクトのルール（`.cursorrules` や `.clauderules`）から汎用ルールを抽出する際の判断基準：

1. **汎用化すべきルール**:
   - 複数のプロジェクトで適用可能な原則
   - 技術スタックに依存しないベストプラクティス
   - 開発プロセスや品質管理に関するルール
   - セキュリティやパフォーマンスに関する一般的な指針

2. **プロジェクト固有として残すべきルール**:
   - 特定のプロジェクト名やモジュール名を含むルール
   - 特定の技術スタックに強く依存する実装詳細
   - プロジェクト固有のビジネスロジックや制約

3. **抽出プロセス**:
   ```
   既存ルールの分析
       ↓
   汎用化可能な部分の特定
       ↓
   プロジェクト固有部分の除去
       ↓
   共通ルールとして再構成
       ↓
   レビュー・マージ
   ```

## **3\. 運用・整備方針**

### **共通化の原則 (Write Once, Apply Everywhere)**

* **コアロジックの分離**: 不変的なルールは `core/` 下の Markdown ファイルに記述します。  
* **更新の同期**: 共通ルールを修正し、各プロジェクトで `git submodule update` を行うことで、全プロジェクトのAIに最新の規約を反映させます。

### **ルールの優先順位（重要度順）**

ルールが競合した場合、以下の優先順位で適用されます（上位が優先）：

1. **プロジェクト固有の上書き** (`.rules/overrides.md`) - 最優先
2. **プロジェクト固有の仕様** (`.rules/project-specs.md`)
3. **共通ルール** (`.ai-rules/core/*.md`)
4. **AIツールのデフォルト動作**

この優先順位をラッパーファイル内で明示することで、AIが一貫した判断を行えます。

### **ルールファイルの構造化ガイド**

各ルールファイル（`core/*.md`）は以下の構造を推奨します：

```markdown
# タイトル

## 概要
このルールの目的と適用範囲

## 基本原則
- 原則1
- 原則2

## 具体的な指針
### ケース1
対応方法...

## 例外・特別なケース
特定の状況での対応...

## 参考リンク
関連するドキュメントやリソース
```

この構造により、AIがルールを理解しやすく、保守性も向上します。

## **4\. 利用手順とラッパーの記述例**

### **ステップ1: サブモジュールとして取り込む**

対象プロジェクトのリポジトリで、本リポジトリをサブモジュールとして追加します。

```bash
# 新規プロジェクトへの導入
git submodule add https://github.com/your-org/vibe-coding-standard-rules.git .ai-rules
git submodule update --init --recursive

# 既存プロジェクトへの導入（既にサブモジュールがある場合）
git submodule add https://github.com/your-org/vibe-coding-standard-rules.git .ai-rules
cd .ai-rules
git checkout main  # または適切なブランチ/タグ
cd ..
git add .ai-rules .gitmodules
git commit -m "Add AI rules submodule"
```

**注意事項**:
* サブモジュールのパスは `.ai-rules` を推奨（`.gitignore` で除外されないよう注意）
* 特定のバージョン（タグ）を固定したい場合は、サブモジュール内で `git checkout <tag>` を実行

### **ステップ1.5: Cursor/Claude Codeでの利用確認**

サブモジュール追加後、AIツールがルールを正しく読み込めるか確認します。

#### **Cursorでの確認方法**

1. **Cursorを再起動**: サブモジュール追加後、Cursorを再起動してルールを読み込み直します
2. **ルールファイルの確認**: Cursorの設定画面で `.cursorrules` が正しく認識されているか確認
3. **動作確認**: 簡単な質問（例：「このプロジェクトのコーディング規約を教えて」）でルールが適用されているか確認

#### **Claude Codeでの確認方法**

1. **Claude Codeを再起動**: サブモジュール追加後、Claude Codeを再起動
2. **ルールファイルの確認**: `.clauderules` がプロジェクトルートに存在するか確認
3. **動作確認**: 簡単な質問でルールが適用されているか確認

#### **トラブルシューティング**

**問題**: AIツールがルールを読み込めない

**解決方法**:
```bash
# 1. サブモジュールが正しく初期化されているか確認
ls -la .ai-rules/core/

# 2. ラッパーファイルのパスが正しいか確認
cat .cursorrules  # または .clauderules

# 3. 相対パスが正しいか確認（プロジェクトルート基準）
pwd  # プロジェクトルートにいることを確認

# 4. ファイルが実際に存在するか確認
test -f .ai-rules/core/base-prompt.md && echo "OK" || echo "MISSING"
```

### **ステップ2: ラッパーファイルの具体的記述例**

ラッパーファイルは、AIに対する「読み込み指示書」です。以下の内容を記述して、共通ルールと個別ルールを紐付けます。

#### **Cursor (`.cursorrules`) の記述例**

Cursorはファイルの相関関係を理解するのが得意です。`@` 記法や相対パスを明示します。

```
# AI Coding Rules for This Project

## 1. Core Standards (Global)
Always adhere to the global coding standards and base behavior defined in the following files. 
You must read these to understand the foundational rules of this organization:
- .ai-rules/core/base-prompt.md
- .ai-rules/core/coding-style.md
- .ai-rules/core/architecture.md
- .ai-rules/core/test-standard.md
- .ai-rules/core/security.md
- .ai-rules/core/error-handling.md
- .ai-rules/core/logging.md
- .ai-rules/core/configuration.md

## 2. Cursor Skills
Available skills are automatically detected from:
- `.cursor/skills/` (project-level)
- `~/.cursor/skills/` (user-level, global)

Use skills when appropriate. Type `/` in Agent chat to see available skills.

## 3. Project Specific Rules (Local)
For logic specific to this repository, prioritize the rules in:
- .rules/project-specs.md
- .rules/overrides.md

**Priority**: If there is a conflict, `.rules/overrides.md` > `.rules/project-specs.md` > `.ai-rules/core/*.md`

## 4. Development Context
- Primary Tech Stack: Next.js (App Router), Tailwind CSS, TypeScript
- Environment: Use Node.js v20
- Package Manager: pnpm
- Code Style: ESLint + Prettier (config in .eslintrc.json)

## 5. Error Handling
If any referenced rule file is missing, inform the user and continue with available rules.
Do not fail silently - always mention when a rule file cannot be found.
```

**ベストプラクティス**:
* ファイルパスは相対パスで記述（プロジェクトルート基準）
* 読み込む順序を明示（共通ルール → プロジェクト固有ルール）
* エラーハンドリングの指示を含める
* 技術スタックや環境情報を具体的に記載
* Cursor Skillsの利用を明示

#### **Claude Code (`.clauderules`) の記述例**

Claude Codeは指示に従順です。最初に「どのファイルに目を通すべきか」をタスクとして明示します。

```
# Instruction
You are an expert developer. Before starting any task, you must internalize the global and local rules provided in this repository.

# Task: Read Rule Files (in order)
Before proceeding with any coding task, read and understand the following rule files in this exact order:

1. Global Base Behavior: `.ai-rules/core/base-prompt.md`
   - Understand the communication style and thought process expected
   
2. Global Coding Standards: `.ai-rules/core/coding-style.md`
   - Learn naming conventions, directory structure, and recommended libraries
   
3. Global Architecture: `.ai-rules/core/architecture.md`
   - Understand architectural principles and patterns
   
4. Global Testing Standards: `.ai-rules/core/test-standard.md`
   - Understand testing requirements and coverage expectations
   
5. Global Security: `.ai-rules/core/security.md`
   - Learn security best practices and secret handling
   
6. Global Error Handling: `.ai-rules/core/error-handling.md`
   - Understand error handling principles and patterns
   
7. Global Logging: `.ai-rules/core/logging.md`
   - Understand logging principles and patterns
   
8. Global Configuration: `.ai-rules/core/configuration.md`
   - Understand configuration management principles

9. Project Specifications: `.rules/project-specs.md`
   - Understand project-specific architectural decisions and constraints

10. Project Overrides: `.rules/overrides.md` (if exists)
    - These rules take precedence over all global rules

# Available Agents
Use specialized agents when appropriate:
- `/plan` or planner agent: For creating implementation plans
- code-reviewer agent: For code quality and security review
- tdd-guide agent: For TDD workflow guidance

# Available Commands
- `/tdd`: Test-driven development workflow
- `/plan`: Create implementation plan
- `/code-review`: Review code quality

# Priority Order
Rule priority (highest to lowest):
1. `.rules/overrides.md`
2. `.rules/project-specs.md`
3. `.ai-rules/core/*.md`

# Project Context
- Tech Stack: Next.js (App Router), Tailwind CSS, TypeScript
- Node.js Version: v20
- Package Manager: pnpm

# Error Handling
If a rule file is missing, inform the user immediately and continue with available rules.
```

**ベストプラクティス**:
* タスク形式で明確に指示（「Read and understand」など）
* 読み込み順序を番号付きで明示
* 各ファイルの目的を簡潔に説明
* 優先順位を明確に記載
* 利用可能なエージェントとコマンドを明示

## **5\. プロジェクト内での個別化（カスタマイズ）**

プロジェクト固有の事情（例：特定のライブラリ使用、レガシーコードへの対応）は、導入先リポジトリの `.rules/` フォルダで管理します。

### **導入先リポジトリの推奨構成**

```
target-project/
├── .ai-rules/              # [共通] サブモジュール（共通の教科書）
├── .rules/                 # [個別] このプロジェクト専用のルール
│   ├── project-specs.md    # プロジェクト独自の仕様
│   └── overrides.md        # 共通ルールを上書きしたい内容
├── .cursorrules            # [ラッパー] Cursor用の目次
└── .clauderules            # [ラッパー] Claude Code用の目次
```

### **プロジェクト固有ルールの書き方ガイド**

#### **`project-specs.md` の記述例**

```markdown
# Project Specifications

## Architecture
- Framework: Next.js 14 with App Router
- State Management: Zustand
- Styling: Tailwind CSS + shadcn/ui

## Key Libraries
- Form Handling: react-hook-form + zod
- API Client: tRPC
- Date Handling: date-fns

## Project-Specific Conventions
- Component naming: PascalCase with descriptive names
- File structure: Feature-based organization under `app/`
- API routes: All under `/api/v1/` prefix
```

#### **`overrides.md` の記述例**

```markdown
# Rule Overrides

## Purpose
This file contains project-specific overrides to global rules.
These rules take precedence over all rules in `.ai-rules/core/`.

## Overrides

### Coding Style
- **Override**: Use 2 spaces instead of 4 for indentation (legacy codebase compatibility)
- **Reason**: Existing codebase uses 2 spaces, consistency is prioritized

### Testing
- **Override**: Unit test coverage threshold is 70% (instead of global 80%)
- **Reason**: Legacy components have lower coverage, gradual improvement planned
```

**重要**: `overrides.md` は慎重に使用し、上書きの理由を必ず記載してください。将来的に共通ルールを更新することで不要になる可能性があります。

## **6\. 更新のループ**

### **共通ルールの更新フロー**

1. **ルールの提案**: プロジェクトで良いルールを思いつく、または既存ルールの問題点を発見
2. **共通化の判断**: 複数プロジェクトで有効なルールか判断
   - 複数プロジェクトで有効 → 共通ルール（`.ai-rules/core/`）に追加
   - プロジェクト固有 → プロジェクトの `.rules/` に追加
3. **Pull Request**: 共通リポジトリへ Pull Request を送る
   - 変更内容の説明
   - 影響範囲の記載
   - 既存プロジェクトへの影響評価
4. **レビュー・マージ**: レビュー後、マージ
5. **各プロジェクトでの更新**: 各プロジェクトでサブモジュールを更新

### **サブモジュールの更新手順**

#### **手動更新**

```bash
# プロジェクトルートで実行
cd .ai-rules
git fetch origin
git checkout main  # または最新のタグ
git pull origin main
cd ..
git add .ai-rules
git commit -m "Update AI rules submodule"
```

#### **自動更新（推奨）**

CI/CDパイプラインに組み込むことで、定期的に更新を確認できます。

```yaml
# .github/workflows/update-rules.yml の例
name: Update AI Rules
on:
  schedule:
    - cron: '0 0 * * 1'  # 毎週月曜日
  workflow_dispatch:

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true
      - name: Update submodule
        run: |
          git submodule update --remote .ai-rules
          git add .ai-rules
          git diff --staged --quiet || git commit -m "chore: update AI rules submodule"
          git push
```

### **ルールの非推奨化・削除プロセス**

共通ルールを削除または大幅に変更する場合：

1. **非推奨化の通知**: 変更予定を共通リポジトリの `CHANGELOG.md` に記載
2. **移行期間の設定**: 少なくとも1ヶ月の移行期間を設ける
3. **プロジェクトへの通知**: 影響を受けるプロジェクトに通知
4. **段階的な削除**: 移行期間後に削除または変更を実施

## **7\. 既存プロジェクトへの移行**

### **段階的な導入**

既存プロジェクトに導入する場合、以下の段階的アプローチを推奨します：

1. **フェーズ1: サブモジュールの追加**
   - サブモジュールを追加し、ラッパーファイルを作成
   - 既存の開発フローに影響を与えないよう、最小限のルールから開始

2. **フェーズ2: プロジェクト固有ルールの整理**
   - 既存のコーディング規約を `.rules/project-specs.md` に移行
   - 共通ルールとの差分を `.rules/overrides.md` に記載

3. **フェーズ3: 段階的な共通ルール適用**
   - 新規コードから共通ルールを適用
   - 既存コードは段階的にリファクタリング

### **移行チェックリスト**

- [ ] サブモジュールの追加完了
- [ ] ラッパーファイル（`.cursorrules`, `.clauderules`）の作成
- [ ] プロジェクト固有ルールの整理・文書化
- [ ] チームメンバーへの説明・共有
- [ ] ルールファイルの動作確認（AIツールでテスト）
- [ ] `.gitignore` の確認（`.ai-rules/` が除外されていないか）

## **8\. トラブルシューティング**

### **よくある問題と解決方法**

#### **問題1: サブモジュールが空のディレクトリとして表示される**

**原因**: サブモジュールが初期化されていない

**解決方法**:
```bash
git submodule update --init --recursive
```

#### **問題2: AIツールがルールファイルを読み込めない**

**原因**: パスが間違っている、またはファイルが存在しない

**解決方法**:
- ラッパーファイル内のパスを確認（相対パスが正しいか）
- 実際にファイルが存在するか確認: `ls -la .ai-rules/core/`
- エラーハンドリングの指示をラッパーファイルに追加

#### **問題3: ルールが競合している、または期待通りに動作しない**

**原因**: 優先順位が不明確、またはルールの記述が曖昧

**解決方法**:
- ラッパーファイルで優先順位を明示
- ルールファイルの構造を見直し（セクション分け、具体例の追加）
- `.rules/overrides.md` で明示的に上書き

#### **問題4: サブモジュールの更新が反映されない**

**原因**: サブモジュールが特定のコミット/タグに固定されている

**解決方法**:
```bash
cd .ai-rules
git fetch origin
git checkout main  # または最新のタグ
cd ..
git add .ai-rules
git commit -m "Update AI rules"
```

### **ルールファイルの検証方法**

ルールファイルが正しく機能しているか確認する方法：

1. **手動確認**: AIツールに簡単な質問をして、ルールに従った回答が返るか確認
2. **ファイル存在確認**: スクリプトで参照されているファイルが存在するか確認
   ```bash
   # 例: ラッパーファイルで参照されているファイルの存在確認
   grep -E "\.ai-rules|\.rules" .cursorrules | sed 's/.*- //' | xargs -I {} test -f {} && echo "OK: {}" || echo "MISSING: {}"
   ```

## **9\. パフォーマンスとベストプラクティス**

### **ルールファイルのサイズ管理**

* **推奨**: 1ファイルあたり500行以下を目安
* **理由**: AIツールのコンテキストウィンドウを効率的に使用
* **対策**: 大きなルールは複数のファイルに分割（例: `coding-style-typescript.md`, `coding-style-python.md`）

### **ルールの構造化**

* **セクション分け**: 明確な見出しで構造化
* **具体例の提供**: 抽象的なルールだけでなく、具体例を含める
* **メタデータの追加**: ルールの適用範囲、バージョン、更新日などを記載

### **CI/CDとの統合**

ルールの整合性をCI/CDで検証する例：

```yaml
# .github/workflows/validate-rules.yml
name: Validate AI Rules
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true
      - name: Check rule files exist
        run: |
          while IFS= read -r file; do
            if [ ! -f "$file" ]; then
              echo "ERROR: Rule file not found: $file"
              exit 1
            fi
          done < <(grep -E "\.ai-rules|\.rules" .cursorrules | sed 's/.*- //')
```

## **10\. サブモジュール利用の完全ガイド**

### **Cursorでの利用手順（詳細版）**

#### **1. サブモジュールの追加**

```bash
# プロジェクトルートで実行
cd /path/to/your-project

# サブモジュールを追加
git submodule add https://github.com/your-org/vibe-coding-standard-rules.git .ai-rules

# サブモジュールを初期化
git submodule update --init --recursive
```

#### **2. ラッパーファイル（`.cursorrules`）の作成**

プロジェクトルートに `.cursorrules` ファイルを作成します。

```bash
# テンプレートからコピー（推奨）
cp .ai-rules/cursor/.cursorrules.base .cursorrules

# または手動で作成
cat > .cursorrules << 'EOF'
# AI Coding Rules for This Project

## 1. Core Standards (Global)
Always adhere to the global coding standards and base behavior defined in the following files. 
You must read these to understand the foundational rules of this organization:
- .ai-rules/core/base-prompt.md
- .ai-rules/core/coding-style.md
- .ai-rules/core/architecture.md
- .ai-rules/core/test-standard.md
- .ai-rules/core/security.md
- .ai-rules/core/error-handling.md
- .ai-rules/core/logging.md
- .ai-rules/core/configuration.md

## 2. Project Specific Rules (Local)
For logic specific to this repository, prioritize the rules in:
- .rules/project-specs.md
- .rules/overrides.md

**Priority**: If there is a conflict, `.rules/overrides.md` > `.rules/project-specs.md` > `.ai-rules/core/*.md`

## 3. Development Context
- Primary Tech Stack: [Your Tech Stack]
- Environment: [Your Environment]
- Package Manager: [Your Package Manager]
- Code Style: [Your Code Style Tools]

## 4. Error Handling
If any referenced rule file is missing, inform the user and continue with available rules.
Do not fail silently - always mention when a rule file cannot be found.
EOF
```

#### **3. Cursorでの動作確認**

1. **Cursorを再起動**: ラッパーファイル作成後、Cursorを完全に再起動
2. **設定の確認**: Cursorの設定で `.cursorrules` が読み込まれているか確認
3. **テスト質問**: Cursorに「このプロジェクトのコーディング規約を教えて」と質問し、ルールが適用されているか確認

#### **4. ルールの更新**

```bash
# サブモジュールを更新
cd .ai-rules
git fetch origin
git checkout main  # または最新のタグ
git pull origin main
cd ..

# 変更をコミット
git add .ai-rules
git commit -m "Update AI rules submodule"

# Cursorを再起動して新しいルールを読み込む
```

### **Claude Codeでの利用手順（詳細版）**

#### **1. サブモジュールの追加**

```bash
# プロジェクトルートで実行
cd /path/to/your-project

# サブモジュールを追加
git submodule add https://github.com/your-org/vibe-coding-standard-rules.git .ai-rules

# サブモジュールを初期化
git submodule update --init --recursive
```

#### **2. ラッパーファイル（`.clauderules`）の作成**

プロジェクトルートに `.clauderules` ファイルを作成します。

```bash
# テンプレートからコピー（推奨）
cp .ai-rules/claudecode/.clauderules.base .clauderules

# または手動で作成
cat > .clauderules << 'EOF'
# Instruction
You are an expert developer. Before starting any task, you must internalize the global and local rules provided in this repository.

# Task: Read Rule Files (in order)
Before proceeding with any coding task, read and understand the following rule files in this exact order:

1. Global Base Behavior: `.ai-rules/core/base-prompt.md`
   - Understand the communication style and thought process expected
   
2. Global Coding Standards: `.ai-rules/core/coding-style.md`
   - Learn naming conventions, directory structure, and recommended libraries
   
3. Global Architecture: `.ai-rules/core/architecture.md`
   - Understand architectural principles and patterns
   
4. Global Testing Standards: `.ai-rules/core/test-standard.md`
   - Understand testing requirements and coverage expectations
   
5. Global Security: `.ai-rules/core/security.md`
   - Learn security best practices and secret handling
   
6. Global Error Handling: `.ai-rules/core/error-handling.md`
   - Understand error handling principles and patterns
   
7. Global Logging: `.ai-rules/core/logging.md`
   - Understand logging principles and patterns
   
8. Global Configuration: `.ai-rules/core/configuration.md`
   - Understand configuration management principles

9. Project Specifications: `.rules/project-specs.md`
   - Understand project-specific architectural decisions and constraints

10. Project Overrides: `.rules/overrides.md` (if exists)
    - These rules take precedence over all global rules

# Priority Order
Rule priority (highest to lowest):
1. `.rules/overrides.md`
2. `.rules/project-specs.md`
3. `.ai-rules/core/*.md`

# Project Context
- Tech Stack: [Your Tech Stack]
- Node.js Version: [Your Version]
- Package Manager: [Your Package Manager]

# Error Handling
If a rule file is missing, inform the user immediately and continue with available rules.
EOF
```

#### **3. Claude Codeでの動作確認**

1. **Claude Codeを再起動**: ラッパーファイル作成後、Claude Codeを完全に再起動
2. **設定の確認**: Claude Codeの設定で `.clauderules` が読み込まれているか確認
3. **テスト質問**: Claude Codeに「このプロジェクトのコーディング規約を教えて」と質問し、ルールが適用されているか確認

#### **4. ルールの更新**

```bash
# サブモジュールを更新
cd .ai-rules
git fetch origin
git checkout main  # または最新のタグ
git pull origin main
cd ..

# 変更をコミット
git add .ai-rules
git commit -m "Update AI rules submodule"

# Claude Codeを再起動して新しいルールを読み込む
```

### **両ツール共通のベストプラクティス**

1. **定期的な更新**: 週次または月次でサブモジュールを更新し、最新のルールを適用
2. **バージョン固定**: 本番環境では特定のタグに固定して安定性を確保
3. **検証の実施**: ルール更新後は必ず動作確認を実施
4. **チーム共有**: ルール更新時はチームメンバーに通知

## **11\. 今後の拡張検討事項**

### **バージョン管理**

* ルールのバージョニング（セマンティックバージョニング）
* タグベースの固定（安定版と開発版の分離）
* 変更履歴の管理（`CHANGELOG.md`）

### **ルールの検証・テスト**

* ルールファイルの構文チェック
* ルールの適用結果のテスト（サンプルコードで検証）
* ルール間の整合性チェック

### **多言語・多フレームワーク対応**

* 言語別のルールファイル（`core/coding-style-typescript.md` など）
* フレームワーク別のベストプラクティス
* プロジェクトタイプ別のテンプレート

### **ドキュメント生成**

* ルールファイルから自動的にドキュメントを生成
* プロジェクト固有のルール一覧の自動生成
* ルールの適用状況の可視化
