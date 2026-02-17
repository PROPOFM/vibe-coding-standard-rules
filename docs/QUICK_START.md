# クイックスタートガイド

`.ai-rules/`フォルダの中身を確認する方法と、サブモジュールとして利用する手順を説明します。

## `.ai-rules/`フォルダの中身を確認する方法

### 方法1: ターミナルで確認（推奨）

```bash
# サブモジュールとして取り込んだプロジェクトで実行
cd .ai-rules

# ディレクトリ構造を確認
ls -la

# 各ディレクトリの中身を確認
ls -la core/              # コアルール（現在は.gitkeepのみ）
ls -la claude-code/       # Claude Code設定
ls -la cursor/            # Cursor設定
ls -la scripts/          # スクリプト

# 特定のファイルを確認（存在する場合）
cat core/base-prompt.md
cat claude-code/agents/planner.md
cat cursor/.cursorrules.base
```

### 方法2: 確認スクリプトを使用（最も簡単）

```bash
# サブモジュールとして取り込んだプロジェクトで実行
.ai-rules/scripts/check-rules.sh

# このリポジトリ（vibe-coding-standard-rules）内で直接確認する場合
./scripts/check-rules.sh
```

このスクリプトは以下を表示します：
- ディレクトリ構造
- 各ディレクトリ内のファイル一覧
- ファイルの存在状況
- サマリー情報

### 方法3: エディタで確認

1. **VS Code / Cursorで開く**:
   - ファイルエクスプローラーで`.ai-rules/`フォルダを展開
   - 各ディレクトリをクリックして中身を確認

2. **Finder（macOS）で開く**:
   ```bash
   open .ai-rules
   ```

### 方法4: ファイル検索

```bash
# すべてのMarkdownファイルを検索
find .ai-rules -name "*.md" -type f | sort

# 特定のファイルを検索
find .ai-rules -name "base-prompt.md"
find .ai-rules -name "planner.md"

# すべてのファイルを一覧表示
find .ai-rules -type f | sort
```

## 現在のファイル状況

### ✅ 作成済みのファイル

以下のファイルは既に作成されています：

**Claude Code設定**:
- `claude-code/agents/planner.md`
- `claude-code/agents/code-reviewer.md`
- `claude-code/agents/tdd-guide.md`
- `claude-code/commands/tdd.md`
- `claude-code/commands/plan.md`
- `claude-code/rules/security.md`
- `claude-code/rules/testing.md`
- `claude-code/rules/coding-style.md`
- `claude-code/rules/git-workflow.md`
- `claude-code/rules/agents.md`
- `claude-code/rules/auto-mode-commands.md`
- `claude-code/rules/performance.md`
- `claude-code/skills/tdd-workflow/SKILL.md`
- `claude-code/hooks/format-on-edit.json`
- `claude-code/hooks/console-log-warning.json`

**Cursor設定**:
- `cursor/skills/tdd-workflow/SKILL.md`
- `cursor/.cursorrules.base`

**テンプレート**:
- `templates/project-specs.template.md`
- `templates/overrides.template.md`

**スクリプト**:
- `scripts/setup-rules.sh`
- `scripts/validate-rules.sh`
- `scripts/install-claude-code.sh`
- `scripts/check-rules.sh`

### ⚠️ 未作成のファイル（今後追加予定）

以下のファイルは、既存ルール（`docs/reference/existing-ruls.md`）から汎用化して追加する必要があります：

**コアルール**:
- `core/base-prompt.md`
- `core/coding-style.md`
- `core/architecture.md`
- `core/test-standard.md`
- `core/security.md`
- `core/error-handling.md`
- `core/logging.md`
- `core/configuration.md`
- `core/code-review.md`
- `core/development-process.md`
- `core/documentation.md`

**言語固有ルール**:
- `languages/typescript.md`
- `languages/python.md`

**フレームワーク固有ルール**:
- `frameworks/nextjs.md`

**クラウドサービス固有ルール**:
- `cloud-services/gcp.md`
- `cloud-services/bigquery.md`
- `cloud-services/supabase.md`

## サブモジュールとして利用する手順

### ステップ1: サブモジュールの追加

```bash
# プロジェクトルートで実行
git submodule add https://github.com/your-org/vibe-coding-standard-rules.git .ai-rules
git submodule update --init --recursive
```

### ステップ2: 中身の確認

```bash
# 確認スクリプトを実行
.ai-rules/scripts/check-rules.sh

# または手動で確認
cd .ai-rules
ls -la
find . -name "*.md" -type f | sort
```

### ステップ3: ラッパーファイルの作成

```bash
# Cursor用
cp .ai-rules/cursor/.cursorrules.base .cursorrules

# Claude Code用
cp .ai-rules/claude-code/.clauderules.base .clauderules
```

### ステップ4: プロジェクト固有ルールの作成

```bash
# テンプレートから作成
mkdir -p .rules
cp .ai-rules/templates/project-specs.template.md .rules/project-specs.md
cp .ai-rules/templates/overrides.template.md .rules/overrides.md

# 編集
# .rules/project-specs.md にプロジェクト情報を記入
# .rules/overrides.md に必要に応じて上書きルールを記入
```

## トラブルシューティング

### 問題: `.ai-rules/`フォルダが空に見える

**原因**: サブモジュールが初期化されていない

**解決方法**:
```bash
git submodule update --init --recursive
```

### 問題: 特定のファイルが見つからない

**原因**: ファイルがまだ作成されていない（特に`core/`内のファイル）

**解決方法**:
1. ラッパーファイルのエラーハンドリング指示に従う
2. プロジェクト固有ルール（`.rules/project-specs.md`）で補完
3. 共通ルールリポジトリでファイルが追加されるまで待つ

### 問題: ファイルの内容を確認したい

**解決方法**:
```bash
# ファイルが存在する場合
cat .ai-rules/core/base-prompt.md

# ファイルが存在しない場合
echo "ファイルはまだ作成されていません。既存ルールから汎用化して追加する必要があります。"
```

## 次のステップ

1. **既存ルールから汎用ルールを抽出**: `docs/reference/existing-ruls.md`を参照
2. **コアルールファイルを作成**: `core/`ディレクトリに追加
3. **言語・フレームワーク固有ルールを作成**: 必要に応じて追加
4. **クラウドサービス固有ルールを作成**: 必要に応じて追加


