コンテキスト

## エージェントスキル

エージェントスキルは、AI エージェントに専門的な能力を追加するためのオープンな標準仕様です。スキルは、ドメイン固有の知識やワークフローをパッケージ化し、エージェントが特定のタスクを実行する際に利用できるようにします。

## スキルとは？

スキルとは、エージェントにドメイン固有のタスクの実行方法を教える、ポータブルでバージョン管理されたパッケージです。スキルには手順だけでなく、エージェントが実行できるスクリプトやコードを含めることもできます。

ポータブル

スキルは、Agent Skills 標準仕様に対応したあらゆるエージェントで動作します。

バージョン管理

スキルはファイルとして保存され、リポジトリで管理でき、GitHub リポジトリのリンクからインストールすることもできます。

実行可能

スキルには、エージェントがタスクを実行するために動かすスクリプトやコードを含めることができます。

プログレッシブ

スキルはリソースをオンデマンドで読み込み、コンテキスト使用量を効率的に保ちます。

## スキルの仕組み

Cursor の起動時に、スキルディレクトリからスキルを自動的に検出し、Agent で利用できるようにします。Agent には利用可能なスキルが提示され、コンテキストに基づいてどのスキルが適切かを判断します。

スキルは、Agent チャットで `/` を入力してスキル名を検索することで、手動で呼び出すこともできます。

## スキルディレクトリ

スキルは次の場所から自動的に読み込まれます。

| Location | Scope |
| --- | --- |
| `.cursor/skills/` | プロジェクトレベル |
| `.claude/skills/` | プロジェクトレベル（Claude 互換） |
| `.codex/skills/` | プロジェクトレベル（Codex 互換） |
| `~/.cursor/skills/` | ユーザーレベル（グローバル） |
| `~/.claude/skills/` | ユーザーレベル（グローバル、Claude 互換） |
| `~/.codex/skills/` | ユーザーレベル（グローバル、Codex 互換） |

各スキルは、 `SKILL.md` ファイルを含むフォルダである必要があります。

```
.cursor/

└── skills/

    └── my-skill/

        └── SKILL.md
```

スキルには、スクリプト、リファレンス、アセット用の任意のディレクトリを追加で含めることもできます。

```
.cursor/

└── skills/

    └── deploy-app/

        ├── SKILL.md

        ├── scripts/

        │   ├── deploy.sh

        │   └── validate.py

        ├── references/

        │   └── REFERENCE.md

        └── assets/

            └── config-template.json
```

## SKILL.md ファイル形式

各スキルは、YAML フロントマターを持つ `SKILL.md` ファイルで定義します。

```
---

name: my-skill

description: Short description of what this skill does and when to use it.

---

# My Skill

Detailed instructions for the agent.

## When to Use

- Use this skill when...

- This skill is helpful for...

## Instructions

- Step-by-step guidance for the agent

- Domain-specific conventions

- Best practices and patterns

- Use the ask questions tool if you need to clarify requirements with the user
```

### フロントマターのフィールド

| Field | Required | Description |
| --- | --- | --- |
| `name` | Yes | スキルの識別子。小文字の英字、数字、ハイフンのみ使用できます。親フォルダ名と一致している必要があります。 |
| `description` | Yes | スキルの機能と利用タイミングを説明します。エージェントが関連性を判断する際に使用されます。 |
| `license` | No | ライセンス名、またはバンドルされているライセンスファイルへの参照。 |
| `compatibility` | No | 環境要件（システムパッケージ、ネットワークアクセスなど）。 |
| `metadata` | No | 追加メタデータ用の任意のキーと値のマッピング。 |
| `disable-model-invocation` | No | `true` の場合、このスキルは `/skill-name` で明示的に呼び出されたときにのみ使用されます。エージェントはコンテキストに基づいて自動的には適用しません。 |

## 自動呼び出しを無効にする

デフォルトでは、エージェントが関連していると判断したスキルは自動的に呼び出されます。 `disable-model-invocation: true` を設定すると、そのスキルは従来のスラッシュコマンドのように動作し、チャットで明示的に `/skill-name` と入力した場合にのみコンテキストに含まれるようになります。

## スキルへのスクリプトの追加

スキルには、エージェントが実行できるコードを含む `scripts/` ディレクトリを追加できます。 `SKILL.md` では、スキルのルートからの相対パスでスクリプトを参照します。

```
---

name: deploy-app

description: アプリケーションをステージング環境または本番環境にデプロイします。コードのデプロイ時、またはユーザーがデプロイ、リリース、環境について言及した際に使用します。

---

# Deploy App

Deploy the application using the provided scripts.

## Usage

Run the deployment script: \`scripts/deploy.sh <environment>\`

Where \`<environment>\` is either \`staging\` or \`production\`.

## Pre-deployment Validation

Before deploying, run the validation script: \`python scripts/validate.py\`
```

エージェントはこれらの手順を読み、スキルが呼び出されると、そこで指定されたスクリプトを実行します。スクリプトは任意の言語で記述できます。Bash、Python、JavaScript、またはエージェント実装でサポートされているその他の実行可能形式を使用できます。

スクリプトは自己完結型とし、わかりやすいエラーメッセージを含め、エッジケースを適切に処理する必要があります。

## 任意のディレクトリ

スキルでは、次の任意ディレクトリをサポートしています：

| Directory | 目的 |
| --- | --- |
| `scripts/` | エージェントが実行できるコード |
| `references/` | 必要に応じて読み込まれる追加ドキュメント |
| `assets/` | テンプレート、画像、データファイルなどの静的リソース |

メインの `SKILL.md` は要点に絞り、詳細なリファレンス資料は別ファイルに分けてください。こうしておくと、エージェントは必要なときにだけ段階的にリソースを読み込むため、コンテキストの利用が効率的になります。

## スキルを表示する

検出されたスキルを確認するには：

1. **Cursor Settings** を開きます（Mac: Cmd+Shift+J、Windows/Linux: Ctrl+Shift+J）
2. **Rules** に移動します
3. スキルは **Agent Decides** セクションに表示されます

## GitHub からスキルをインストールする

GitHub リポジトリからスキルをインポートできます。

1. **Cursor Settings → Rules** を開く
2. **Project Rules** セクションで **Add Rule** をクリックする
3. **Remote Rule (Github)** を選択する
4. GitHub リポジトリの URL を入力する

## ルールとコマンドをスキルに移行する

Cursor 2.4 には、既存の動的ルールとスラッシュコマンドをスキルに変換するための組み込みスキル `/migrate-to-skills` が含まれています。

この移行スキルは次の項目を変換します：

- **Dynamic rules**: 「Apply Intelligently」設定を使うルール— `alwaysApply: false` （または未定義）で、 `globs` パターンが定義されていないルール。これらは標準スキルに変換されます。
- **Slash commands**: ユーザーレベルおよびワークスペースレベルの両方のコマンドは、 `disable-model-invocation: true` を指定したスキルに変換され、明示的な呼び出し動作が保持されます。

移行手順：

1. Agent チャットで `/migrate-to-skills` と入力します
2. Agent が対象となるルールとコマンドを特定し、スキルに変換します
3. 生成されたスキルを `.cursor/skills/` で確認します

## 詳しく知る

Agent Skills はオープンスタンダードです。詳細は [agentskills.io](https://agentskills.io/) をご覧ください。