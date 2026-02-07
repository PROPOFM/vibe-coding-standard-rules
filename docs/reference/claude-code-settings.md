667

418[tech](https://zenn.dev/tech-or-idea)

Anthropicハッカソン優勝者が10ヶ月以上かけて実際のプロダクト開発で使い込んだ **everything-claude-code** というリポジトリが公開されていたので、内容を読み解いてみました。

## この記事の要約

- **Anthropic x Forum Venturesハッカソン優勝者** が公開した本番環境で使えるClaude Code設定集
- **agents, skills, hooks, commands, rules, MCP設定** の6種類のファイルで構成
- コンテキストウィンドウは **200kから70kまで縮小する可能性** があるため、MCPの有効化は10個以下に抑える
- **TDD（テスト駆動開発）を中心** にしたワークフローで、カバレッジ80%以上を必須とする
- `/tdd` や `/plan` などの **スラッシュコマンド** で素早くワークフローを呼び出せる
- **hooksによる自動化** でフォーマット実行やconsole.log警告を自動化

## 1\. リポジトリの背景と作者について

このリポジトリの作者は [@affaanmustafa](https://x.com/affaanmustafa) 氏です。2025年2月の実験的リリース時期からClaude Codeを使い続けており、2025年9月にはAnthropic x Forum Venturesハッカソンで [@DRodriguezFX](https://x.com/DRodriguezFX) 氏とともに優勝しています。

優勝時に開発したのは [zenith.chat](https://zenith.chat/) というAIを活用したカスタマーディスカバリープラットフォームで、開発は完全にClaude Codeだけで行われたとのことです。

Xで公開されたガイドは **90万view以上、1万以上のブックマーク** を獲得しており、Claude Codeユーザーの間で大きな反響を呼んでいます。

## 2\. ディレクトリ構成の全体像

リポジトリは以下のような構成になっています。

```
everything-claude-code/
├── agents/           # 専門エージェント
├── skills/           # ワークフロー定義とドメイン知識
├── commands/         # スラッシュコマンド
├── rules/            # 常に従うルール
├── hooks/            # トリガーベース自動化
├── mcp-configs/      # MCPサーバー設定
├── plugins/          # プラグイン情報
└── examples/         # 設定例
```

↓リポジトリのキャプチャ  
![](https://storage.googleapis.com/zenn-user-upload/70e30897c331-20260119.png)

それぞれの役割を詳しく見ていきます。

## 3\. agents/：専門エージェントによるタスク委任

agentsディレクトリには、特定のタスクに特化したサブエージェントが定義されています。複雑な作業をメインのClaudeから切り離して委任する仕組みです。

| ファイル | 役割 |
| --- | --- |
| `planner.md` | 機能実装の計画立案 |
| `architect.md` | システム設計・アーキテクチャ決定 |
| `tdd-guide.md` | テスト駆動開発のガイド |
| `code-reviewer.md` | コード品質・セキュリティレビュー |
| `security-reviewer.md` | 脆弱性分析（OWASP Top 10対応） |
| `build-error-resolver.md` | ビルドエラー解決 |
| `e2e-runner.md` | PlaywrightによるE2Eテスト |
| `refactor-cleaner.md` | 不要コードの削除 |
| `doc-updater.md` | ドキュメントの同期更新 |

エージェントファイルは **frontmatter形式** で定義されています。

```
---
name: code-reviewer
description: Reviews code for quality, security, and maintainability
tools: Read, Grep, Glob, Bash
model: opus
---

You are a senior code reviewer...
```

重要なポイントは `tools` の指定です。サブエージェントに **必要最小限のツールだけを与える** ことで、実行が高速になり、フォーカスも維持されます。50個のツールを持つエージェントより、5個に絞ったエージェントの方が効率的に動作するとのことです。

## 4\. skills/：再利用可能なワークフロー定義

skillsディレクトリには、コマンドやエージェントが呼び出すワークフロー定義が格納されています。

| ファイル | 内容 |
| --- | --- |
| `coding-standards.md` | 言語別ベストプラクティス |
| `backend-patterns.md` | API・データベース・キャッシュパターン |
| `frontend-patterns.md` | React・Next.jsパターン |
| `project-guidelines-example.md` | プロジェクト固有スキルの例 |
| `tdd-workflow/` | TDD手法の詳細定義 |
| `security-review/` | セキュリティチェックリスト |
| `clickhouse-io.md` | ClickHouseアナリティクス |

特に `tdd-workflow` は **RED → GREEN → REFACTOR** のサイクルを定義しており、80%以上のテストカバレッジを必須としています。

skillsは `~/.claude/skills/` （ユーザー共通）または `.claude/skills/` （プロジェクト固有）に配置して使います。

## 5\. commands/：スラッシュコマンドで素早く実行

commandsディレクトリには、 `/tdd` のように呼び出せるクイック実行用のコマンドが定義されています。

| コマンド | 説明 |
| --- | --- |
| `/tdd` | テスト駆動開発ワークフロー |
| `/plan` | 実装計画の作成（ユーザー確認待ち） |
| `/e2e` | E2Eテスト生成 |
| `/code-review` | 品質レビュー |
| `/build-fix` | ビルドエラー修正 |
| `/refactor-clean` | 不要コード削除 |
| `/test-coverage` | カバレッジ分析 |
| `/update-codemaps` | コードマップ更新 |
| `/update-docs` | ドキュメント同期 |

skillsとcommandsの違いは **保存場所と呼び出し方法** です。

- **skills**: `~/.claude/skills/` に配置、広範なワークフロー定義
- **commands**: `~/.claude/commands/` に配置、素早く実行可能なプロンプト

複数のコマンドを一度に呼び出すことも可能で、例えば `/tdd` の後に `/refactor-clean` を実行するようなチェーンも組めます。

## 6\. rules/：常に従うべきガイドライン

rulesディレクトリには、プロジェクト全体で常に適用されるガイドラインが格納されています。

| ファイル | 内容 |
| --- | --- |
| `security.md` | 必須セキュリティチェック |
| `coding-style.md` | 不変性、ファイル構成 |
| `testing.md` | TDD、80%カバレッジ要件 |
| `git-workflow.md` | コミット形式、PR手順 |
| `agents.md` | エージェントの使用タイミング |
| `performance.md` | モデル選択、コンテキスト管理 |
| `patterns.md` | APIレスポンス形式、フック |
| `hooks.md` | フックのドキュメント |

セキュリティルールでは、コミット前に以下のチェックを必須としています。

- ハードコードされたシークレットがないこと
- すべてのユーザー入力がバリデートされていること
- 適切なエラーハンドリングがあること
- 依存関係に既知の脆弱性がないこと

rulesファイルは **モジュラーに分割** することが推奨されています。一つの巨大なファイルより、役割ごとに分けた方が管理しやすくなります。

## 7\. hooks/：イベント駆動の自動化

hooksディレクトリには、ツール実行時に自動で発火するフックが定義されています。

| フック種類 | タイミング | 例 |
| --- | --- | --- |
| `PreToolUse` | ツール実行前 | 特定操作のブロックやリマインド |
| `PostToolUse` | ツール実行後 | 編集後に自動フォーマット |
| `Stop` | セッション終了前 | console.log警告 |

READMEには、TypeScript/JavaScriptファイル編集時に `console.log` の残存を警告するフックの例が紹介されています。

```
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\\\.(ts|tsx|js|jsx)$\"",
  "hooks": [{
    "type": "command",
    "command": "#!/bin/bash\ngrep -n 'console\\.log' \"$file_path\" && echo '[Hook] Remove console.log' >&2"
  }]
}
```

このフックは、ファイル編集後に自動で `console.log` を検出し、開発者に削除を促します。本番環境へのデバッグコード混入を防ぐための仕組みです。

## 8\. mcp-configs/：外部サービス連携

mcp-configsディレクトリには、MCPサーバーの設定が格納されています。READMEによると、GitHub、Supabase、Vercel、Railwayなどの外部サービスとの連携設定が含まれているとのことです。

ここで **最も重要な注意点** があります。

**MCPを有効化しすぎると、コンテキストウィンドウが大幅に縮小します。** 200kあったコンテキストが70kまで減少する可能性があるとのことです。

推奨される運用方法は以下の通りです。

- 20〜30個のMCPを設定ファイルに記述
- プロジェクトごとに **10個以下を有効化**
- 有効なツールは **80個以下** に抑える

使わないMCPは `disabledMcpServers` で無効化しておくことが重要です。

## 9\. クイックスタートとまとめ

このリポジトリを使い始めるための手順を整理しておきます。

```
# リポジトリをクローン
git clone https://github.com/affaan-m/everything-claude-code.git

# agentsをコピー
cp everything-claude-code/agents/*.md ~/.claude/agents/

# rulesをコピー
cp everything-claude-code/rules/*.md ~/.claude/rules/

# commandsをコピー
cp everything-claude-code/commands/*.md ~/.claude/commands/

# skillsをコピー
cp -r everything-claude-code/skills/* ~/.claude/skills/
```

hooksは `~/.claude/settings.json` に追加し、MCP設定は `~/.claude.json` に追加します。MCP設定内の `YOUR_*_HERE` プレースホルダーは、実際のAPIキーに置き換えてください。

everything-claude-codeの設計思想をまとめると以下の通りです。

- **エージェントファーストデザイン**: 複雑なタスクは専門エージェントに委任
- **TDD中心のワークフロー**: RED→GREEN→REFACTORサイクルと80%カバレッジ
- **セキュリティファースト**: コミット前の必須チェック
- **コンテキストウィンドウ管理**: MCPの有効化は控えめに

すべての設定をそのまま使う必要はありません。自分のワークフローに合うものを選んで取り入れ、不要なものは削除し、独自のパターンを追加していくのが良いかと思います。

## 参考リンク

- [everything-claude-code リポジトリ](https://github.com/affaan-m/everything-claude-code)
- [The Shorthand Guide to Everything Claude Code（Xスレッド）](https://x.com/affaanmustafa/status/2012378465664745795)
- [zenith.chat](https://zenith.chat/)

## 紹介

以下はAnthropicの評価についての記事なので、こちらもぜひ読んでください。

667

418