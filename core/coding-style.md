# Coding Style

コーディングスタイルと命名規則に関する共通ルールです。

## 概要

このルールは、命名規則、ディレクトリ構造、推奨ライブラリなどのコーディングスタイルを定義します。プロジェクト全体で一貫性を保つための基本原則です。

## 基本原則

### 1. 命名規則

**変数・関数**:
- **camelCase**: 変数名、関数名、メソッド名
- **PascalCase**: クラス名、型名、インターフェース名
- **UPPER_SNAKE_CASE**: 定数名
- **kebab-case**: ファイル名、ディレクトリ名（プロジェクトによって異なる）

**命名のベストプラクティス**:
- 意味のある名前を使用（略語を避ける）
- 動詞で始まる関数名（`get`, `set`, `create`, `update`, `delete`等）
- 名詞で始まる変数名（`user`, `config`, `data`等）
- ブール値は`is`, `has`, `should`等で始める

### 2. ディレクトリ構造

**推奨ディレクトリ構造**:
```
src/
├── config/          # 設定管理
├── services/        # サービス層
│   ├── base/        # 基底クラス
│   ├── external/    # 外部APIサービス
│   └── database/    # データベースサービス
├── types/           # 型定義
└── utils/           # ユーティリティ
```

**ディレクトリ命名規則**:
- 小文字で統一
- ハイフン区切り（`kebab-case`）または単語区切り
- 意味のある名前を使用

### 3. ファイル構造

**ファイル命名規則**:
- クラスファイル: `PascalCase.ts`（例: `UserService.ts`）
- ユーティリティファイル: `camelCase.ts`（例: `dateHelper.ts`）
- 型定義ファイル: `types.ts`または`*.types.ts`
- 設定ファイル: `config.ts`または`*.config.ts`

**ファイルの組織化**:
- 1ファイル1クラス/関数（可能な限り）
- 関連する機能を同じディレクトリに配置
- 循環依存を避ける

### 4. コードの組織化

**インポート順序**:
```typescript
// 1. 外部ライブラリ
import express from 'express';
import { createClient } from '@supabase/supabase-js';

// 2. 内部モジュール（共通基盤）
import { config } from '@project/common';
import { logger } from '@project/common';

// 3. 相対インポート
import { UserService } from './services/UserService';
import { userTypes } from './types';
```

**エクスポート**:
- 名前付きエクスポートを優先
- デフォルトエクスポートは必要な場合のみ
- バレルエクスポート（`index.ts`）を活用

### 5. コード品質

**DRY原則（Don't Repeat Yourself）**:
- 重複コードを避ける
- 共通ロジックを関数・クラスに抽出
- 再利用可能なコンポーネントを作成

**単一責任の原則**:
- 1つの関数・クラスは1つの責務のみ
- 関数は小さく、焦点を絞る
- クラスは明確な目的を持つ

**可読性の重視**:
- コードは自己文書化を心がける
- コメントは「なぜ」を説明（「何を」はコードで表現）
- 複雑なロジックは関数に分割

## 具体的な指針

### 関数の書き方

**良い例**:
```typescript
// 明確な関数名、単一責任、適切な型
function calculateTotalPrice(items: CartItem[]): number {
  return items.reduce((total, item) => total + item.price * item.quantity, 0);
}
```

**悪い例**:
```typescript
// 曖昧な関数名、複数の責務、型が不明確
function calc(items: any[]): any {
  let total = 0;
  for (let i = 0; i < items.length; i++) {
    total += items[i].p * items[i].q;
  }
  return total;
}
```

### クラスの書き方

**良い例**:
```typescript
// 明確なクラス名、単一責任、適切な型
class UserService {
  constructor(private userRepository: UserRepository) {}

  async getUserById(id: string): Promise<User | null> {
    return await this.userRepository.findById(id);
  }
}
```

### エラーハンドリング

**早期リターンの活用**:
```typescript
// ✅ 良い例：早期リターンでネストを減らす
function processUser(user: User | null): Result {
  if (!user) {
    return { success: false, error: 'User not found' };
  }
  
  if (!user.isActive) {
    return { success: false, error: 'User is not active' };
  }
  
  // メインロジック
  return { success: true, data: user };
}
```

### 型定義

**型の明示**:
```typescript
// ✅ 良い例：型を明示
interface User {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

function createUser(data: CreateUserInput): User {
  // ...
}
```

## 推奨ライブラリ・ツール

### コード品質

- **ESLint**: コード品質チェック
- **Prettier**: コードフォーマット
- **TypeScript**: 型安全性

### テスト

- **Jest**: テストフレームワーク
- **ts-jest**: TypeScript用Jest設定

### 開発ツール

- **nodemon**: 開発時の自動再起動
- **concurrently**: 複数コマンドの並列実行

## 例外・特別なケース

### レガシーコードへの対応

既存のコードベースに導入する場合:
- 段階的な適用を実施
- 新規コードから適用
- 既存コードは段階的にリファクタリング

### プロジェクト固有の規約

プロジェクト固有の命名規則がある場合:
- `.rules/project-specs.md`に記載
- 共通ルールとの差分を明確化
- チーム内で合意形成

## 参考リンク

- [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)

