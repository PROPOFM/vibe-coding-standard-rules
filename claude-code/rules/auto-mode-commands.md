# Claude Code 自動実行許可コマンド（Auto-mode）

Claude Code の「Auto-mode」を最大限に活用し、承認待ちによる中断を減らすための推奨設定です。セキュリティを担保しつつ、開発効率を上げるために以下を遵守すること。

## 1. 読み取り・探索系（推奨度：最高）

ファイルの変更を伴わないため、**常に許可（Allow all）**に設定してもリスクが非常に低い。AI の状況把握スピードが向上する。

| コマンド | 用途 |
| :---- | :---- |
| ls, find, fd | ディレクトリ構造の確認 |
| cat, bat, read | ファイル内容の閲覧 |
| grep, rg (ripgrep) | コード内の文字列検索 |
| git diff | 変更内容の差分確認 |
| git status, git log | リポジトリの状態や履歴の確認 |
| pwd | 現在の作業ディレクトリの確認 |

**ルール**: 上記のコマンドは許可リストに含めることを推奨する。実行時はユーザー承認を待たずに進めてよいとみなせる設定を推奨する。

## 2. 検証・品質管理系（推奨度：高）

「修正 → テスト → 再修正」のループを自律的に回せるようにする。

| カテゴリ | コマンド例 |
| :---- | :---- |
| **テスト実行** | npm test, pytest, go test, vitest, bundle exec rspec |
| **型チェック** | tsc (TypeScript), mypy (Python) |
| **リンター** | eslint, flake8, rubocop |
| **フォーマッタ** | prettier --check, black --check |

**ルール**: 上記は品質確認のため頻繁に実行する。許可リストに含めることを推奨する。

## 3. 環境・依存関係の確認（推奨度：中）

環境差異によるエラーを防ぐために頻繁に使用する。

- node -v, npm -v, python --version
- npm list --depth=0, pip list, go list
- env（機密情報が含まれる場合は注意が必要）
- docker ps, docker images

**ルール**: プロジェクトで使用するランタイム・パッケージマネージャに応じて許可を検討する。`env` は機密を含む可能性があるため、共有サーバーでは許可しない。

## 4. プロジェクト固有のビルド系

プロジェクトの構成に応じて追加を検討する。

- npm run build
- make
- go build

**ルール**: リポジトリに `package.json` / `Makefile` / `go.mod` 等がある場合、対応するビルドコマンドを許可リストに加えることを検討する。

## 5. npm 系・Vite 系（推奨度：高）

フロント／Node プロジェクトでよく使う以下のコマンドは、**Auto-mode に含めて問題ない**。

| カテゴリ | コマンド例 | 備考 |
| :---- | :---- | :---- |
| **テスト** | npm test, npm run test, vitest, npx vitest | 読み取り＋実行のみで破壊的でない |
| **ビルド** | npm run build, vite build, npx vite build | 成果物出力のみ（例: dist/） |
| **型チェック** | npx tsc --noEmit | 読み取りのみ |
| **開発サーバー** | npm run dev, vite | 起動のみ。ファイル変更は HMR でユーザーコードに依存 |
| **確認系** | npm -v, node -v, npm list --depth=0 | 既に「環境・依存関係の確認」に含む |

**ルール**: 上記は許可リストに含めてよい。`npm run` は **スクリプト名まで固定**（例: `npm run build`）で許可する想定。汎用の `npm run` 単体はスクリプト内容次第で破壊的になり得るため、許可するなら「よく使うスクリプト名」に限定する。

### npm で手動確認を推奨するもの

| コマンド | 理由 |
| :---- | :---- |
| npm install, npm ci | node_modules と lock を書き換える。依存の改ざんリスクがあるため、初回 or 依存更新時は手動確認が無難。チーム方針で許可する場合は可。 |
| npx &lt;任意パッケージ名&gt; | 任意コード実行になり得る。npx vitest など**コマンド固定**なら許可してよい。 |

## 6. git 系（推奨度：読み取りは最高、書き込みは要検討）

### Auto-mode に含めてよい（読み取り・探索）

リポジトリの状態を変えず、状況把握に使うコマンド。**許可を強く推奨**する。

| コマンド | 用途 |
| :---- | :---- |
| git status | 作業ツリー・ステージの状態 |
| git diff | 変更内容の差分（ワーキング／ステージ） |
| git log, git log --oneline | コミット履歴 |
| git show | 指定コミットの内容 |
| git branch, git branch -a | ブランチ一覧 |
| git remote -v | リモート設定の確認 |
| git rev-parse --abbrev-ref HEAD | 現在ブランチ名 |
| git tag -l | タグ一覧 |
| git stash list | stash 一覧 |
| git reflog | 参照ログ（履歴の追跡） |

### Auto-mode に含めてよい（ローカル操作・チーム次第）

リモートに影響せず、ローカルだけを変える操作。チーム方針で許可するかを決める。

| コマンド | 用途 | 備考 |
| :---- | :---- | :---- |
| git add &lt;path&gt; | ステージング | 変更内容は git diff で確認済みの想定 |
| git commit -m "..." | コミット | 「何をコミットするか」をユーザーが把握している前提で許可可 |
| git checkout -b &lt;branch&gt;, git switch -c &lt;branch&gt; | 新規ブランチ作成 | 破壊的でない |
| git switch &lt;branch&gt;, git checkout &lt;branch&gt; | ブランチ切り替え | 未コミット変更がある場合は注意 |

**ルール**: 上記は「AI がステージ・コミット・ブランチ操作まで自律的に行ってよい」とする場合に許可する。必ずしも全チームで許可する必要はない。

### git で手動確認を推奨するもの

| コマンド | 理由 |
| :---- | :---- |
| git push | リモートを更新するため、意図したタイミングで実行したいことが多い。許可してもよいが、初回は手動推奨。 |
| git pull, git pull --rebase | リモートの取り込み。マージ／rebase でローカル履歴が変わる。 |
| git merge | マージ結果を確認してから進めたい場合がある。 |
| git rebase &lt;branch&gt; | 履歴の書き換え。コンフリクト時は特に手動が無難。 |
| git stash push, git stash pop | 作業の退避・復元。pop でコンフリクトの可能性。 |
| git restore &lt;file&gt;, git checkout -- &lt;file&gt; | ワーキングツリーの破棄。意図しない取り消しを防ぐため手動推奨。 |

### git で許可すべきではないもの（既存「破壊的な操作」と合わせる）

- git reset --hard（ローカル変更の破棄）
- git push --force, git push -f（履歴の強制上書き）
- git clean -fd（未追跡ファイルの削除）
- git checkout -- ., git restore .（全変更の一括破棄）

---

## 許可すべきではない（手動確認を必須とする）コマンド

予期せぬ破壊的変更や情報漏洩を防ぐため、**毎回手動で承認する**こと。これらは許可リストに含めない。

### 破壊的な操作

- rm -rf（ディレクトリ削除）
- git reset --hard（変更の破棄）
- git push --force（履歴の強制上書き）

### デプロイ・インフラ操作

- terraform apply, aws s3 sync
- vercel --prod, firebase deploy

### 外部通信

- curl, wget（意図しないスクリプトの実行防止）

**ルール**: 上記を実行する必要がある場合は、必ずユーザーに説明し、明示的な承認を得てから実行する。Auto-mode の許可リストには追加しない。

---

## 設定のヒント

1. **スモールスタート**: まずは ls と grep だけを許可する。
2. **頻度の観察**: AI が何度も承認を求めてくる「安全なコマンド」をその都度許可リストに加える。
3. **セッション管理**: 作業が終わったら、必要に応じて許可設定をリセットまたは見直す。

**注意**: 共有サーバーや機密性の高い環境では、Allow all の範囲を最小限に留めること。
