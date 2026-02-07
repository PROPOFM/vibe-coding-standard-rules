# Configuration Management

設定管理の原則（環境変数、設定ファイル等）に関する共通ルールです。

## 概要

このルールは、設定管理の原則、環境変数の管理方法、設定ファイルの一元管理を定義します。環境に依存する設定を適切に管理するための基本原則です。

## 基本原則

### 1. 設定管理の原則

**設定管理の基本方針**:
- 設定は一元管理する
- 環境変数で環境別の設定を管理
- 設定ファイルのパスは相対パスで統一
- 設定の読み込みエラーを適切に処理

**設定の分類**:
- **環境変数**: 環境に依存する設定（DB接続情報等）
- **設定ファイル**: アプリケーション設定（デフォルト値等）
- **シークレット**: 機密情報（APIキー、パスワード等）

### 2. 環境変数の管理

**環境変数の命名規則**:
- **UPPER_SNAKE_CASE**: 環境変数名
- **明確な名前**: 意味が明確な名前を使用
- **プレフィックス**: プロジェクト名やサービス名をプレフィックスに使用

**環境変数の設定方法**:
```bash
# 環境変数の設定
export DATABASE_URL="postgresql://localhost:5432/mydb"
export API_KEY="your_api_key"
export NODE_ENV="production"
```

**環境変数の読み込み**:
```typescript
// ✅ 良い例：環境変数の適切な読み込み
const databaseUrl = process.env['DATABASE_URL'];
if (!databaseUrl) {
  throw new Error('DATABASE_URL is not set');
}
```

### 3. 設定ファイルの一元管理

**設定ファイルの配置**:
- 設定ファイルは共通基盤で一元管理
- 設定ファイルのパスは相対パスで統一
- どのディレクトリから実行しても同じパスでアクセス可能

**設定ファイルの構造**:
```typescript
// 設定ファイルの構造例
interface AppConfig {
  database: {
    url: string;
    poolSize: number;
  };
  api: {
    timeout: number;
    retryCount: number;
  };
  logging: {
    level: string;
    format: string;
  };
}
```

### 4. 設定の読み込みパターン

**設定読み込みの実装パターン**:
```typescript
// 設定マネージャークラス
class ConfigManager {
  private config: AppConfig;
  
  constructor() {
    this.config = this.loadConfig();
  }
  
  private loadConfig(): AppConfig {
    return {
      database: {
        url: process.env['DATABASE_URL'] || 'default_url',
        poolSize: parseInt(process.env['DB_POOL_SIZE'] || '10', 10)
      },
      api: {
        timeout: parseInt(process.env['API_TIMEOUT'] || '5000', 10),
        retryCount: parseInt(process.env['API_RETRY_COUNT'] || '3', 10)
      },
      logging: {
        level: process.env['LOG_LEVEL'] || 'info',
        format: process.env['LOG_FORMAT'] || 'json'
      }
    };
  }
  
  getConfig(): AppConfig {
    return this.config;
  }
}
```

## 具体的な指針

### 環境別設定の管理

**環境別設定の実装**:
```typescript
// 環境別設定の取得
function getEnvironmentConfig(): AppConfig {
  const env = process.env['NODE_ENV'] || 'development';
  
  const baseConfig = {
    // 共通設定
  };
  
  const envConfig = {
    development: {
      // 開発環境設定
    },
    production: {
      // 本番環境設定
    }
  };
  
  return { ...baseConfig, ...envConfig[env] };
}
```

### 設定の検証

**設定値の検証**:
```typescript
// 設定値の検証
function validateConfig(config: AppConfig): void {
  if (!config.database.url) {
    throw new Error('DATABASE_URL is required');
  }
  
  if (config.api.timeout < 0) {
    throw new Error('API_TIMEOUT must be positive');
  }
}
```

### 設定のエラーハンドリング

**設定読み込み失敗時の対応**:
```typescript
// 設定読み込みのエラーハンドリング
try {
  const config = loadConfig();
  validateConfig(config);
} catch (error) {
  console.error('Failed to load configuration:', error.message);
  console.error('Config file path:', configPath);
  console.error('Environment variables:', Object.keys(process.env));
  process.exit(1);
}
```

### シークレット管理

**シークレットの管理**:
- 環境変数で管理（`.env`ファイルは`.gitignore`に追加）
- シークレット管理サービスを活用（AWS Secrets Manager、GCP Secret Manager等）
- ハードコードを禁止

## 禁止事項

**❌ やってはいけないこと**:
- 設定ファイルのパスをハードコードする
- 環境変数をエクスポートせずにアプリケーションを実行する
- シークレットをコードにハードコードする
- 設定読み込みのテストを行わずに本番実行する
- エラーメッセージを詳細にしない

**✅ 必ずやること**:
- 設定ファイルのパスを相対パスで統一
- 環境変数を明示的にエクスポート
- シークレットは環境変数またはシークレット管理サービスで管理
- 設定読み込みのテストを実施
- エラー時の詳細なデバッグ情報を提供

## 例外・特別なケース

### レガシーコードへの対応

既存のコードベースに導入する場合:
- 段階的な設定管理の統一
- 新規コードから設定マネージャーを適用
- 既存コードは段階的に移行

### プロジェクト固有の設定

プロジェクト固有の設定がある場合:
- `.rules/project-specs.md`に記載
- 共通ルールとの差分を明確化
- チーム内で合意形成

## 参考リンク

- [12-Factor App: Config](https://12factor.net/config)
- [Environment Variables Best Practices](https://www.twilio.com/blog/environment-variables-javascript)

