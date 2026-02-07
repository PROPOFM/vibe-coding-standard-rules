# Error Handling

エラーハンドリングの原則と実装パターンに関する共通ルールです。

## 概要

このルールは、エラーハンドリングの原則、カスタムエラーの実装パターン、エラーレベルとステータスコードの設定方法を定義します。堅牢なアプリケーションを構築するための基本原則です。

## 基本原則

### 1. エラーハンドリングの原則

**エラーハンドリングの基本方針**:
- すべてのエラーを適切に処理する
- エラーメッセージは明確で有用な情報を含む
- エラーログに詳細な情報を含める
- ユーザーには適切なエラーメッセージを表示

**エラーハンドリングの階層**:
1. **アプリケーションレベル**: ビジネスロジックエラー
2. **システムレベル**: システムエラー（DB接続エラー等）
3. **外部レベル**: 外部APIエラー

### 2. カスタムエラーの実装

**カスタムエラークラスの設計**:
```typescript
// ベースエラークラス
class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public errorCode: string,
    public isOperational: boolean = true
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

// 特定のエラータイプ
class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 400, 'VALIDATION_ERROR');
  }
}

class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 404, 'NOT_FOUND');
  }
}

class DatabaseError extends AppError {
  constructor(message: string) {
    super(message, 500, 'DATABASE_ERROR', false);
  }
}
```

**エラーレベルの定義**:
- **Operational Errors**: 予期されるエラー（バリデーションエラー等）
- **Programming Errors**: 予期しないエラー（バグ等）

### 3. エラーレベルとステータスコード

**HTTPステータスコードの使い分け**:
- **400 Bad Request**: クライアントのリクエストエラー
- **401 Unauthorized**: 認証が必要
- **403 Forbidden**: 認可が拒否された
- **404 Not Found**: リソースが見つからない
- **409 Conflict**: リソースの競合
- **500 Internal Server Error**: サーバーエラー
- **503 Service Unavailable**: サービスが利用不可

**エラーレベルの設定**:
```typescript
// エラーレベルの定義
enum ErrorLevel {
  LOW = 'low',           // 警告レベル
  MEDIUM = 'medium',     // 注意レベル
  HIGH = 'high',         // エラーレベル
  CRITICAL = 'critical'  // 致命的エラー
}
```

### 4. エラーログの記録

**エラーログに含める情報**:
- エラーメッセージ
- エラースタックトレース
- リクエスト情報（URL、メソッド、パラメータ等）
- ユーザー情報（可能な場合）
- タイムスタンプ
- エラーレベル

**エラーログの実装例**:
```typescript
try {
  // 処理
} catch (error) {
  logger.error('Error occurred', {
    error: error.message,
    stack: error.stack,
    request: {
      url: req.url,
      method: req.method,
      params: req.params
    },
    level: ErrorLevel.HIGH
  });
  
  // エラーレスポンス
  res.status(500).json({
    error: 'Internal server error',
    errorCode: 'INTERNAL_ERROR'
  });
}
```

## 具体的な指針

### 非同期処理のエラーハンドリング

**Promise/async-await**:
```typescript
// ✅ 良い例：適切なエラーハンドリング
async function processData(data: InputData): Promise<Result> {
  try {
    const validated = await validateData(data);
    const processed = await processValidatedData(validated);
    return { success: true, data: processed };
  } catch (error) {
    if (error instanceof ValidationError) {
      throw error; // 再スロー
    }
    throw new DatabaseError('Failed to process data');
  }
}
```

### エラーの伝播

**エラーの伝播パターン**:
```typescript
// エラーを適切に伝播
async function serviceMethod(): Promise<void> {
  try {
    await databaseOperation();
  } catch (error) {
    // エラーをラップして再スロー
    throw new ServiceError('Service operation failed', error);
  }
}
```

### エラーレスポンスの形式

**統一されたエラーレスポンス形式**:
```typescript
interface ErrorResponse {
  error: string;
  errorCode: string;
  statusCode: number;
  details?: Record<string, unknown>;
  timestamp: string;
}
```

**エラーレスポンスの実装例**:
```typescript
function sendErrorResponse(
  res: Response,
  error: AppError,
  details?: Record<string, unknown>
): void {
  res.status(error.statusCode).json({
    error: error.message,
    errorCode: error.errorCode,
    statusCode: error.statusCode,
    details,
    timestamp: new Date().toISOString()
  });
}
```

### エラーの分類

**エラーの分類**:
- **Validation Errors**: 入力値の検証エラー
- **Business Logic Errors**: ビジネスルール違反
- **System Errors**: システムエラー（DB接続エラー等）
- **External Errors**: 外部APIエラー

## 例外・特別なケース

### 本番環境でのエラーハンドリング

**本番環境での注意事項**:
- スタックトレースをユーザーに表示しない
- 機密情報をエラーメッセージに含めない
- エラーログに詳細情報を記録
- エラー監視システムに通知

### レガシーコードへの対応

既存のコードベースに導入する場合:
- 段階的なエラーハンドリングの改善
- 新規コードからカスタムエラーを適用
- 既存コードは段階的にリファクタリング

## 参考リンク

- [Error Handling Best Practices](https://www.joyent.com/node-js/production/design/errors)
- [TypeScript Error Handling](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4.0.html#unknown-on-catch-clause-bindings)

