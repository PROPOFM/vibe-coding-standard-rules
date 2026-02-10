# Claude Code Configuration

このディレクトリには、Claude Code用の設定ファイルが含まれます。

## ディレクトリ構成

- `agents/`: 専門エージェント（frontmatter形式）
- `skills/`: ワークフロー定義
- `commands/`: スラッシュコマンド（`/tdd`, `/plan`など）
- `rules/`: 常に従うルール（モジュラーに分割）
- `hooks/`: トリガーベース自動化
- `mcp-configs/`: MCPサーバー設定
- `settings-template.json`: Claude Code設定テンプレート（自動実行設定含む）

## セットアップ手順

### 1. 設定ファイルのインストール

```bash
# スクリプトを使用してインストール
cd .cursor/vibe-coding-standard-rules
./scripts/install-claude-code.sh
```

または手動でコピー：

```bash
# Agents
cp -r claude-code/agents/* ~/.claude/agents/

# Skills
cp -r claude-code/skills/* ~/.claude/skills/

# Commands
cp -r claude-code/commands/* ~/.claude/commands/

# Rules
cp -r claude-code/rules/* ~/.claude/rules/
```

### 2. 設定ファイルの設定

#### `~/.claude/settings.json` の設定

`settings-template.json`を参考に、`~/.claude/settings.json`を作成または更新します：

```bash
# テンプレートをコピー
cp claude-code/settings-template.json ~/.claude/settings.json

# または、既存の設定にマージ
# テンプレートの内容を手動で ~/.claude/settings.json に追加
```

**重要な設定項目**:

- `agent.autoExecute: true` - コマンド実行の自動承認（Yolo Mode）
- `agent.yoloMode: true` - 確認なしで実行
- `agent.confirmBeforeExecute: false` - 実行前の確認を無効化

#### `~/.claude.json` の設定（MCP設定）

MCPサーバーの設定は`mcp-configs/README.md`を参照してください。

**重要**: 有効なMCPサーバーは10個以下に抑えてください（コンテキストウィンドウの縮小を防ぐため）。

### 3. Claude Codeの再起動

設定を変更した後、Claude Codeを完全に再起動してください。

## 自動実行設定について

### 設定の優先順位

1. **プロジェクト固有設定**: `~/.claude/settings.json`（グローバル）
2. **プロジェクト設定**: `.cursor/settings.json`（Cursor IDE用、Claude Codeには直接影響しない）

### 自動実行が有効にならない場合

1. **設定ファイルの場所を確認**
   - Claude Code用: `~/.claude/settings.json`
   - Cursor IDE用: `.cursor/settings.json` または `~/Library/Application Support/Cursor/User/settings.json`

2. **設定項目を確認**
   ```json
   {
     "agent": {
       "autoExecute": true,
       "yoloMode": true,
       "confirmBeforeExecute": false
     }
   }
   ```

3. **Claude Codeを再起動**
   - 設定変更後は必ず再起動が必要です

4. **VM内での設定**
   - VM内でClaude Codeを使用している場合、VM内の`~/.claude/settings.json`を設定してください
   - ローカルマシンの設定はVM内には反映されません

## 利用可能な機能

### エージェント

- `planner.md`: 実装計画の作成
- `tdd-guide.md`: テスト駆動開発のガイド
- `code-reviewer.md`: コードレビュー

### コマンド

- `/tdd`: テスト駆動開発ワークフロー
- `/plan`: 実装計画の作成

### フック

- `format-on-edit.json`: 編集後の自動フォーマット
- `console-log-warning.json`: console.logの警告

詳細は各ディレクトリのREADMEを参照してください。

