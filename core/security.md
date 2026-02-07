# Security

セキュリティ対策、秘密情報の扱いに関する共通ルールです。

## 概要

このルールは、セキュリティ対策の基本原則、秘密情報の管理方法、OWASP Top 10への対応を定義します。安全なアプリケーションを構築するための基本原則です。

## 基本原則

### 1. 秘密情報の管理

**秘密情報の管理原則**:
- 機密情報は環境変数で管理
- `.env`ファイルは`.gitignore`に追加
- 本番環境では適切なシークレット管理サービスを使用
- コミット履歴に秘密情報を含めない

**秘密情報の種類**:
- APIキー、トークン
- データベース接続情報
- パスワード
- 秘密鍵

**秘密情報の管理方法**:
```typescript
// ✅ 良い例：環境変数から取得
const apiKey = process.env['API_KEY'];
if (!apiKey) {
  throw new Error('API_KEY is not set');
}

// ❌ 悪い例：ハードコード
const apiKey = 'sk_live_1234567890abcdef';
```

### 2. 入力値の検証

**入力値検証の原則**:
- すべてのユーザー入力を検証
- XSS（Cross-Site Scripting）対策
- SQLインジェクション対策
- ファイルアップロードの検証

**入力値検証の実装**:
```typescript
// 入力値の検証
function validateInput(input: UserInput): void {
  if (!input.email || !isValidEmail(input.email)) {
    throw new ValidationError('Invalid email format');
  }
  
  if (input.password && input.password.length < 8) {
    throw new ValidationError('Password must be at least 8 characters');
  }
}
```

### 3. 認証・認可

**認証・認可の原則**:
- 保護されたルートに認証チェックを実装
- ユーザー権限のチェックを実装
- セッション管理を適切に実装
- パスワードは適切にハッシュ化（bcrypt、argon2等）

**認証の実装例**:
```typescript
// 認証ミドルウェア
function authenticate(req: Request, res: Response, next: NextFunction): void {
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  if (!token) {
    return res.status(401).json({ error: 'Authentication required' });
  }
  
  try {
    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}
```

### 4. エラーメッセージ

**エラーメッセージの原則**:
- エラーメッセージに機密情報を含めない
- スタックトレースを本番環境で表示しない
- 適切なエラーメッセージをユーザーに表示

**エラーメッセージの実装**:
```typescript
// ✅ 良い例：機密情報を含めない
catch (error) {
  logger.error('Database error', { error: error.message });
  res.status(500).json({ error: 'Internal server error' });
}

// ❌ 悪い例：機密情報を含む
catch (error) {
  res.status(500).json({ 
    error: error.message,
    stack: error.stack,
    connectionString: dbConfig.connectionString
  });
}
```

### 5. 依存関係のセキュリティ

**依存関係の管理**:
- 依存関係の脆弱性をスキャン
- 古いパッケージを更新
- 不要な依存関係を削除

**脆弱性スキャン**:
```bash
# 依存関係の脆弱性スキャン
npm audit

# 自動修正（可能な場合）
npm audit fix
```

## OWASP Top 10への対応

### 1. Broken Access Control

**対策**:
- 認可チェックをすべての保護されたリソースに実装
- 最小権限の原則を適用
- アクセス制御のテストを実施

### 2. Cryptographic Failures

**対策**:
- 機密データを適切に暗号化
- 強力な暗号化アルゴリズムを使用
- 暗号化キーを適切に管理

### 3. Injection

**対策**:
- パラメータ化クエリを使用（SQLインジェクション対策）
- 入力値の検証とサニタイズ
- ORMを使用してクエリを安全に実行

### 4. Insecure Design

**対策**:
- セキュリティを設計段階から考慮
- 脅威モデリングを実施
- セキュリティレビューを実施

### 5. Security Misconfiguration

**対策**:
- デフォルト設定を変更
- 不要な機能を無効化
- セキュリティ設定を適切に構成

### 6. Vulnerable Components

**対策**:
- 依存関係の脆弱性を定期的にチェック
- 依存関係を最新の安全なバージョンに更新
- 依存関係の変更を監視

### 7. Authentication Failures

**対策**:
- 強力なパスワードポリシーを実装
- 多要素認証を実装
- セッション管理を適切に実装

### 8. Software and Data Integrity Failures

**対策**:
- 依存関係の整合性を検証
- CI/CDパイプラインのセキュリティを確保
- コード署名を実施

### 9. Security Logging Failures

**対策**:
- セキュリティイベントをログに記録
- ログの整合性を確保
- ログの監視とアラートを実装

### 10. Server-Side Request Forgery (SSRF)

**対策**:
- 外部リクエストの検証を実施
- ホワイトリスト方式で許可されたURLのみ許可
- ネットワークセグメンテーションを実施

## コミット前のセキュリティチェック

**必須チェック項目**:
- [ ] ハードコードされたシークレットがないこと
- [ ] すべてのユーザー入力がバリデートされていること
- [ ] 適切なエラーハンドリングがあること
- [ ] 依存関係に既知の脆弱性がないこと
- [ ] 認証・認可が適切に実装されていること

## 例外・特別なケース

### レガシーコードへの対応

既存のコードベースに導入する場合:
- 段階的なセキュリティ改善
- 新規コードからセキュリティ原則を適用
- 既存コードは段階的にリファクタリング

## 参考リンク

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)

