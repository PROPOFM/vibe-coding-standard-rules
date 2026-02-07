# TypeScript Rules

TypeScript固有のルールとベストプラクティスです。

## 概要

このルールは、TypeScript固有のコーディング規約、型定義の原則、コンパイラ設定を定義します。型安全で保守性の高いコードを書くための基本原則です。

## 基本原則

### 1. 型チェックの厳密化

**推奨されるTypeScript設定**:
```json
{
  "compilerOptions": {
    "strict": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true
  }
}
```

**厳密な型チェックの利点**:
- 実行時エラーの削減
- コードの可読性向上
- IDEの補完機能の向上
- リファクタリングの安全性向上

### 2. 環境変数のアクセス

**環境変数のアクセス方法**:
```typescript
// ✅ 良い例：型安全な環境変数アクセス
const databaseUrl = process.env['DATABASE_URL'];
if (!databaseUrl) {
  throw new Error('DATABASE_URL is not set');
}

// ❌ 悪い例：型が不明確
const databaseUrl = process.env.DATABASE_URL;
```

**環境変数の型定義**:
```typescript
// 環境変数の型定義
interface EnvironmentVariables {
  DATABASE_URL: string;
  API_KEY: string;
  NODE_ENV: 'development' | 'production' | 'test';
}

function getEnvVar(key: keyof EnvironmentVariables): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`${key} is not set`);
  }
  return value;
}
```

### 3. オプショナルプロパティ

**オプショナルプロパティの明示**:
```typescript
// ✅ 良い例：オプショナルプロパティを明示
interface User {
  id: string;
  name: string;
  email: string | undefined;  // 明示的にundefinedを許可
  createdAt: Date;
}

// ❌ 悪い例：オプショナルプロパティが不明確
interface User {
  id: string;
  name: string;
  email?: string;  // undefinedが含まれるか不明確
  createdAt: Date;
}
```

### 4. 型定義の集約

**型定義の配置**:
- 型定義は`src/types/`ディレクトリに集約
- 関連する型は同じファイルに配置
- 共通で使用される型は共通基盤で定義

**型定義ファイルの構造**:
```typescript
// src/types/user.ts
export interface User {
  id: string;
  name: string;
  email: string;
}

export interface CreateUserInput {
  name: string;
  email: string;
}

export type UserStatus = 'active' | 'inactive' | 'suspended';
```

### 5. 型の推論と明示

**型推論の活用**:
```typescript
// ✅ 良い例：型推論を活用
const users = ['user1', 'user2'];  // string[]と推論

// 明示が必要な場合のみ型を指定
const userId: string = getUserId();
```

**型の明示が必要な場合**:
- 関数の戻り値型（公開API）
- 複雑な型
- 型推論が困難な場合

## 具体的な指針

### 関数の型定義

**関数の型定義**:
```typescript
// ✅ 良い例：明示的な型定義
function calculateTotal(items: CartItem[]): number {
  return items.reduce((total, item) => total + item.price, 0);
}

// 非同期関数
async function fetchUser(id: string): Promise<User | null> {
  // ...
}
```

### クラスの型定義

**クラスの型定義**:
```typescript
// ✅ 良い例：適切な型定義
class UserService {
  constructor(
    private userRepository: UserRepository,
    private logger: Logger
  ) {}
  
  async getUserById(id: string): Promise<User | null> {
    return await this.userRepository.findById(id);
  }
}
```

### ジェネリクスの使用

**ジェネリクスの活用**:
```typescript
// ✅ 良い例：型安全なジェネリクス
function mapArray<T, U>(
  array: T[],
  mapper: (item: T) => U
): U[] {
  return array.map(mapper);
}
```

### 型ガードの使用

**型ガードの実装**:
```typescript
// 型ガード関数
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'name' in obj
  );
}

// 型ガードの使用
if (isUser(data)) {
  // dataはUser型として扱える
  console.log(data.name);
}
```

## 禁止事項

**❌ やってはいけないこと**:
- `any`型を安易に使用する
- 型アサーション（`as`）を過度に使用する
- 型定義を省略する（公開API）
- 環境変数アクセスで型安全性を無視する

**✅ 必ずやること**:
- 厳密な型チェックを有効化
- 環境変数アクセスは`process.env['VAR_NAME']`形式を使用
- オプショナルプロパティは`| undefined`を明示
- 型定義は`src/types/`ディレクトリに集約

## 例外・特別なケース

### レガシーコードへの対応

既存のコードベースに導入する場合:
- 段階的な型の追加
- `any`型から段階的に改善
- 新規コードから厳密な型チェックを適用

### サードパーティライブラリ

サードパーティライブラリの型定義:
- `@types/*`パッケージを活用
- 型定義がない場合は`.d.ts`ファイルを作成
- 型定義の品質を確認

## 参考リンク

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [TypeScript Deep Dive](https://basarat.gitbook.io/typescript/)
- [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)

