# Supabase Rules

Supabase操作と設定管理に関するルールです。

## 概要

このルールは、Supabase操作の原則、設定管理の一元化、環境別設定の管理方法を定義します。Supabaseを操作する際は、必ず共通基盤の設定定義を参照することが重要です。

## 基本原則

### 1. 設定参照の原則

**🚨 重要な原則：共通基盤の設定を必ず参照**

**Supabaseを操作する際は、必ず共通基盤の設定定義を参照すること。**

**すべてのSupabase操作で共通基盤の設定を使用**:
- **環境設定**: 共通基盤の環境設定ファイル
- **データベース設定**: 共通基盤のデータベース設定ファイル
- **環境変数管理**: 共通基盤の環境変数管理機能

### 2. プロジェクトIDとURLの取得方法

**開発環境**:
```typescript
// 共通基盤の設定から取得
import { getEnvironmentConfig } from '@project/common';

const config = getEnvironmentConfig();
// 開発環境の場合
const projectId = config.supabase.projectId;
const url = config.supabase.url;
```

**環境変数での上書き**:
```bash
# 環境変数が設定されている場合は優先
export SUPABASE_ENVIRONMENT="development"
export SUPABASE_PROJECT_ID="[DEV_SUPABASE_PROJECT_ID]"
export SUPABASE_URL="https://[DEV_SUPABASE_PROJECT_ID].supabase.co"
```

### 3. Supabase CLI操作時の設定参照

**スクリプトでの設定参照**:
```bash
# 共通基盤の設定を参照
COMMON_ROOT="$(cd "$PROJECT_ROOT/../common" && pwd)"

# 環境変数から設定を取得、なければ共通基盤のデフォルト値を使用
if [ -z "$SUPABASE_PROJECT_ID" ]; then
  SUPABASE_PROJECT_ID="[DEV_SUPABASE_PROJECT_ID]"  # 共通基盤のデフォルト値
fi

if [ -z "$SUPABASE_PROJECT_REF" ]; then
  SUPABASE_PROJECT_REF="[DEV_SUPABASE_PROJECT_ID]"  # 共通基盤のデフォルト値
fi
```

### 4. マイグレーション操作時の設定参照

**マイグレーション適用時**:
```bash
# 共通基盤の設定を参照してプロジェクトIDを取得
cd module-name

# 環境変数が設定されていない場合は、共通基盤のデフォルト値を使用
export SUPABASE_ENVIRONMENT="development"
export SUPABASE_PROJECT_ID="[DEV_SUPABASE_PROJECT_ID]"  # 共通基盤のデフォルト値

# Supabase CLIでマイグレーション適用
supabase link --project-ref "$SUPABASE_PROJECT_ID"
supabase db push --linked
```

### 5. データベース接続時の設定参照

**TypeScript/JavaScriptコード**:
```typescript
// ✅ 正しい方法：共通基盤の設定を使用
import { getEnvironmentConfig } from '@project/common';
import { createClient } from '@supabase/supabase-js';

const config = getEnvironmentConfig();
const supabase = createClient(config.supabase.url, config.supabase.anonKey);
```

**❌ 間違った方法：ハードコード**
```typescript
// ❌ 禁止：ハードコードされた値
const supabase = createClient(
  'https://[DEV_SUPABASE_PROJECT_ID].supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
);
```

### 6. 環境別設定の参照

**環境別の設定取得**:
```typescript
import { getEnvironmentConfig } from '@project/common';

// 環境に応じた設定を自動取得
const config = getEnvironmentConfig();

// 開発環境: '[DEV_SUPABASE_PROJECT_ID]'
// 本番環境: '[PROD_SUPABASE_PROJECT_ID]'
// ローカル環境: '[PROJECT_NAME]-local'
```

## 具体的な指針

### 設定ファイルの一元管理

**共通基盤の設定ファイル**:
- `common/src/config/environment.ts` - 環境別設定
- `common/src/config/database.ts` - データベース設定
- `common/src/config/index.ts` - 設定エクスポート

### 環境別設定の管理

**環境別の設定**:
- **開発環境**: 開発用Supabaseプロジェクト
- **本番環境**: 本番用Supabaseプロジェクト
- **ローカル環境**: ローカルSupabaseインスタンス

### 接続プールとエラーハンドリング

**Supabaseクライアントの管理**:
```typescript
// SupabaseServiceクラスで管理
class SupabaseService {
  private client: SupabaseClient;
  
  constructor() {
    const config = getEnvironmentConfig();
    this.client = createClient(config.supabase.url, config.supabase.anonKey);
  }
  
  async query<T>(queryFn: (client: SupabaseClient) => Promise<T>): Promise<T> {
    try {
      return await queryFn(this.client);
    } catch (error) {
      logger.error('Supabase query failed', { error });
      throw error;
    }
  }
}
```

### トランザクション処理

**トランザクション処理の実装**:
```typescript
// SupabaseTransactionを使用
async function processTransaction(
  transaction: SupabaseTransaction,
  operations: Array<(tx: SupabaseTransaction) => Promise<void>>
): Promise<void> {
  for (const operation of operations) {
    await operation(transaction);
  }
}
```

## MCP (Model Context Protocol) 設定の管理

### MCP設定の基本方針

**🚨 重要な原則：秘密情報や個別情報は設定ファイルに含めない**

**MCP設定ファイル（`.cursor/mcp.json`、`~/.claude.json`）には以下を含めない**:
- ❌ プロジェクトID（環境変数から動的に生成）
- ❌ API Keys（Anon Key、Service Role Key）
- ❌ Access Token
- ❌ その他の認証情報

**✅ 設定ファイルには以下を含める**:
- ✅ 設定の構造（テンプレート）
- ✅ 環境変数参照の方法
- ✅ 設定生成スクリプトへの参照

### MCP設定の管理方法

**1. 環境変数ベースの一元管理**

**ローカル開発環境**:
- `.env`ファイルで環境変数を管理
- `.gitignore`に含まれているため、Gitにコミットされない

**CI/CD環境**:
- GitHub Secretsで環境変数を管理
- Cloud Build Secretsで環境変数を管理

**2. 設定ファイルの自動生成**

環境変数から設定ファイルを自動生成するスクリプトを使用：

```bash
# 環境変数からMCP設定を生成
npm run mcp:generate
```

このスクリプトは以下を生成：
- `.cursor/mcp.json` - Cursor用MCP設定
- `docs/setup/claude-code-mcp-config.json` - Claude Code用設定テンプレート

**3. MCP設定ファイルの構造**

**Cursor設定（`.cursor/mcp.json`）**:
```json
{
  "mcpServers": {
    "supabase-dev": {
      "url": "https://mcp.supabase.com/mcp?project_ref=${SUPABASE_DEV_PROJECT_ID}&read_only=false"
    },
    "supabase-prod": {
      "url": "https://mcp.supabase.com/mcp?project_ref=${SUPABASE_PROD_PROJECT_ID}&read_only=true"
    }
  }
}
```

**Claude Code設定（`~/.claude.json`）**:
```json
{
  "mcpServers": {
    "supabase-dev": {
      "url": "https://mcp.supabase.com/mcp?project_ref=${SUPABASE_DEV_PROJECT_ID}&read_only=false"
    },
    "supabase-prod": {
      "url": "https://mcp.supabase.com/mcp?project_ref=${SUPABASE_PROD_PROJECT_ID}&read_only=true"
    }
  }
}
```

**注意**: Claude Codeの設定ファイルでは環境変数の展開は行われません。スクリプトで生成した値を直接使用してください。

### GitHub Secretsでの管理

**設定するGitHub Secrets**:

**開発環境**:
- `SUPABASE_DEV_PROJECT_ID`
- `SUPABASE_DEV_URL`
- `SUPABASE_DEV_ANON_KEY`
- `SUPABASE_DEV_SERVICE_ROLE_KEY`
- `SUPABASE_DEV_ACCESS_TOKEN`

**本番環境**:
- `SUPABASE_PROD_PROJECT_ID`
- `SUPABASE_PROD_URL`
- `SUPABASE_PROD_ANON_KEY`
- `SUPABASE_PROD_SERVICE_ROLE_KEY`
- `SUPABASE_PROD_ACCESS_TOKEN`

**GitHub Actionsでの使用例**:
```yaml
- name: Set up environment variables
  env:
    SUPABASE_DEV_PROJECT_ID: ${{ secrets.SUPABASE_DEV_PROJECT_ID }}
    SUPABASE_PROD_PROJECT_ID: ${{ secrets.SUPABASE_PROD_PROJECT_ID }}
  run: |
    echo "SUPABASE_DEV_PROJECT_ID=$SUPABASE_DEV_PROJECT_ID" >> $GITHUB_ENV
    echo "SUPABASE_PROD_PROJECT_ID=$SUPABASE_PROD_PROJECT_ID" >> $GITHUB_ENV

- name: Generate MCP config
  run: npm run mcp:generate
```

### MCP設定の更新手順

**プロジェクトIDが変更された場合**:

1. `.env`ファイルを更新
2. スクリプトを再実行：
   ```bash
   npm run mcp:generate
   ```
3. Cursorを再起動
4. Claude Codeの設定を手動で更新（`~/.claude.json`）

**GitHub Secretsの更新**:

1. GitHubリポジトリのSettings > Secrets and variables > Actionsに移動
2. 該当するSecretを更新
3. CI/CDパイプラインが自動的に新しい値を使用

## 禁止事項

**❌ やってはいけないこと**:
- プロジェクトIDやURLをハードコードする
- 共通基盤の設定を無視して独自の設定を使用する
- 環境変数なしで直接Supabaseに接続する
- 各モジュールで個別にSupabase設定を定義する
- **MCP設定ファイルに秘密情報や個別情報を含める**
- **MCP設定ファイルをGitにコミットする（プロジェクト固有の情報を含む場合）**

**✅ 必ずやること**:
- 共通基盤の設定を参照する
- 環境変数で設定を上書き可能にする
- 環境別の設定を自動的に取得する
- 設定の一元管理を維持する
- **MCP設定は環境変数から自動生成する**
- **秘密情報はGitHub Secretsや環境変数で管理する**

## 例外・特別なケース

### レガシーコードへの対応

既存のコードベースに導入する場合:
- 段階的な設定の統一
- 新規コードから共通基盤の設定を適用
- 既存コードは段階的に移行

## 参考リンク

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Client Library](https://supabase.com/docs/reference/javascript/introduction)
- [Supabase CLI](https://supabase.com/docs/guides/cli)

