# Logging

ログ管理の原則と実装パターンに関する共通ルールです。

## 概要

このルールは、ログ管理の原則、構造化ログの実装、ログレベルの使い分けを定義します。運用・監視を効率的に行うための基本原則です。

## 基本原則

### 1. ログ管理の原則

**ログ管理の基本方針**:
- 構造化ログ（JSON形式）を使用
- ログレベルを適切に設定
- メタデータを含むログを推奨
- 本番環境では不要なログを削減

**ログの目的**:
- **デバッグ**: 問題の原因特定
- **監視**: システムの状態監視
- **監査**: 操作履歴の記録
- **分析**: パフォーマンス分析

### 2. ログレベル

**ログレベルの定義**:
- **error**: エラーが発生した（処理が失敗した）
- **warn**: 警告（注意が必要だが処理は継続可能）
- **info**: 情報（重要な処理の開始・完了等）
- **debug**: デバッグ情報（開発時の詳細情報）
- **verbose**: 詳細情報（非常に詳細な情報）

**ログレベルの使い分け**:
```typescript
// error: エラーが発生した
logger.error('Database connection failed', { error: error.message });

// warn: 警告
logger.warn('Rate limit approaching', { current: 90, limit: 100 });

// info: 重要な処理
logger.info('User login successful', { userId: user.id });

// debug: デバッグ情報（開発環境のみ）
logger.debug('Processing request', { requestId: req.id });

// verbose: 詳細情報（開発環境のみ）
logger.verbose('Request details', { headers: req.headers });
```

### 3. 構造化ログ

**構造化ログの形式**:
```typescript
// ✅ 良い例：構造化ログ
logger.info('User created', {
  userId: user.id,
  email: user.email,
  timestamp: new Date().toISOString(),
  requestId: req.id
});
```

**ログに含めるメタデータ**:
- タイムスタンプ
- リクエストID（トレーシング用）
- ユーザーID（可能な場合）
- 環境情報
- エラー情報（エラーの場合）

### 4. ログの出力先

**ログの出力先**:
- **開発環境**: コンソール出力
- **本番環境**: ログファイル + ログ管理システム（Cloud Logging等）

**ログローテーション**:
- ログファイルのサイズ制限
- ログファイルの保持期間
- ログファイルの圧縮

## 具体的な指針

### ログの実装パターン

**ログヘルパーの実装**:
```typescript
// ログヘルパークラス
class Logger {
  error(message: string, meta?: Record<string, unknown>): void {
    this.log('error', message, meta);
  }
  
  warn(message: string, meta?: Record<string, unknown>): void {
    this.log('warn', message, meta);
  }
  
  info(message: string, meta?: Record<string, unknown>): void {
    this.log('info', message, meta);
  }
  
  private log(
    level: string,
    message: string,
    meta?: Record<string, unknown>
  ): void {
    const logEntry = {
      level,
      message,
      timestamp: new Date().toISOString(),
      ...meta
    };
    
    // JSON形式で出力
    console.log(JSON.stringify(logEntry));
  }
}
```

### ログのコンテキスト

**リクエストコンテキストの追加**:
```typescript
// リクエストごとのログコンテキスト
function logWithContext(
  logger: Logger,
  req: Request,
  level: string,
  message: string,
  meta?: Record<string, unknown>
): void {
  logger[level](message, {
    requestId: req.id,
    method: req.method,
    url: req.url,
    ...meta
  });
}
```

### パフォーマンスログ

**パフォーマンス測定のログ**:
```typescript
// 処理時間の測定とログ
const startTime = Date.now();
await processData();
const duration = Date.now() - startTime;

logger.info('Data processing completed', {
  duration,
  recordCount: data.length
});
```

### エラーログ

**エラーログの詳細情報**:
```typescript
try {
  await riskyOperation();
} catch (error) {
  logger.error('Operation failed', {
    error: error.message,
    stack: error.stack,
    context: {
      userId: user.id,
      operation: 'riskyOperation'
    }
  });
}
```

## 環境別のログ設定

### 開発環境

**開発環境のログ設定**:
- すべてのログレベルを出力
- コンソール出力
- 詳細なデバッグ情報を含む

### 本番環境

**本番環境のログ設定**:
- `error`, `warn`, `info`のみ出力
- ログファイル + ログ管理システム
- 機密情報を除外
- パフォーマンスを考慮

## 禁止事項

**❌ やってはいけないこと**:
- 機密情報（パスワード、APIキー等）をログに含める
- 過度に詳細なログを出力（パフォーマンス低下）
- ログレベルを適切に設定しない
- 構造化されていないログを出力

**✅ 必ずやること**:
- 構造化ログ（JSON形式）を使用
- ログレベルを適切に設定
- メタデータを含める
- 本番環境では不要なログを削減

## 例外・特別なケース

### デバッグログ

開発時のデバッグログ:
- 開発環境でのみ有効
- 本番環境では無効化
- 環境変数で制御

### 監査ログ

監査が必要な操作:
- ユーザー認証・認可
- 重要なデータ変更
- 管理者操作

## 参考リンク

- [Winston Logging Library](https://github.com/winstonjs/winston)
- [Structured Logging Best Practices](https://www.loggly.com/ultimate-guide/node-logging-basics/)

