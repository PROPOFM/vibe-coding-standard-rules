# BigQuery Rules

BigQueryコスト最適化とクエリ設計に関するルールです。

## 概要

このルールは、BigQueryのコスト最適化、クエリ設計の原則、バッチ処理の実装方法を定義します。BigQueryは従量課金制（$6.25/TB）のため、不適切な実装により高額な課金が発生する可能性があります。

## 基本原則

### 1. コスト最適化の重要性

**🚨 重要：BigQueryは従量課金制**

BigQueryはスキャンしたデータ量に応じて課金されます（$6.25/TB）。
**不適切な実装により、1回の処理で数十万円の課金が発生する可能性があります。**

### 2. クエリ設計の原則

#### 2.1 パーティション条件を必ず含める

```sql
-- ❌ 悪い例：全テーブルスキャン（150MB/クエリ）
SELECT episode_id FROM episodes WHERE episode_id IN UNNEST(@ids)

-- ✅ 良い例：パーティション条件でスキャン量削減（5MB/クエリ）
SELECT episode_id FROM episodes 
WHERE episode_id IN UNNEST(@ids)
  AND published_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
```

**効果**: スキャン量 **97%削減**

#### 2.2 必要なカラムのみSELECT

```sql
-- ❌ 悪い例：全カラム取得
SELECT * FROM episodes WHERE ...

-- ✅ 良い例：必要なカラムのみ
SELECT episode_id, title FROM episodes WHERE ...
```

#### 2.3 LIMIT句の活用

```sql
-- ❌ 悪い例：全件取得
SELECT episode_id FROM episodes WHERE podcast_id = @id

-- ✅ 良い例：必要な件数のみ
SELECT episode_id FROM episodes WHERE podcast_id = @id LIMIT 100
```

### 3. バッチ処理の原則

#### 3.1 個別クエリを避け、バッチ化する

```typescript
// ❌ 悪い例：1件ずつクエリ（8万回のクエリ = 高コスト）
for (const podcast of podcasts) {
  const exists = await checkDuplicate(podcast.episodeId);
}

// ✅ 良い例：バッチでクエリ（160回のクエリ = 低コスト）
const batchSize = 500;
for (let i = 0; i < podcasts.length; i += batchSize) {
  const batch = podcasts.slice(i, i + batchSize);
  const episodeIds = batch.map(p => p.episodeId);
  const existingIds = await checkDuplicatesBatch(episodeIds);
}
```

**効果**: クエリ回数 **99%削減**

#### 3.2 推奨バッチサイズ

| 処理タイプ | 推奨バッチサイズ | 理由 |
|-----------|----------------|------|
| 重複チェック | 500件 | IN句の効率とメモリバランス |
| データ挿入 | 1000件 | Streaming Insertの効率化 |
| データ更新 | 100件 | トランザクション制御のため |

### 4. 高コストエンドポイントの保護

#### 4.1 確認フラグの必須化

大量データを処理するエンドポイントには、必ず確認フラグを実装する。

```typescript
// ✅ 必須実装パターン
app.post('/process/initial', async (req, res) => {
  // Step 1: 環境変数による無効化（デフォルト無効）
  if (process.env['ENABLE_INITIAL_IMPORT'] !== 'true') {
    return res.status(403).json({
      error: 'このエンドポイントは無効化されています',
      howToEnable: '環境変数 ENABLE_INITIAL_IMPORT=true を設定'
    });
  }
  
  // Step 2: 確認フラグの必須化
  if (!req.body.confirmExecution) {
    return res.status(400).json({
      error: '確認フラグが必要です',
      estimatedCost: '¥300,000以上',
      requiredParams: { confirmExecution: true }
    });
  }
  
  // Step 3: 本番環境では追加確認
  if (isProduction && !req.body.confirmProduction) {
    return res.status(400).json({
      error: '本番環境では追加確認が必要です',
      requiredParams: { confirmExecution: true, confirmProduction: true }
    });
  }
  
  // 処理実行...
});
```

#### 4.2 コスト見積もりの表示

高コストなエンドポイントでは、実行前にコスト見積もりを表示する。

```typescript
// レスポンスに推定コストを含める
res.json({
  warning: '⚠️ 高額な課金が発生する可能性があります',
  estimatedCost: '¥300,000以上',
  estimatedScanVolume: '350TB',
  // ...
});
```

### 5. テーブル設計の原則

#### 5.1 パーティショニングの活用

```sql
-- ✅ 日付カラムでパーティション
CREATE TABLE episodes (
  episode_id STRING,
  podcast_id INT64,
  published_at TIMESTAMP,
  -- ...
)
PARTITION BY DATE(published_at)
CLUSTER BY podcast_id, episode_id
```

#### 5.2 クラスタリングの活用

頻繁にフィルタリングするカラムでクラスタリングを設定する。

| テーブル | パーティションカラム | クラスタリングカラム |
|---------|-------------------|-------------------|
| episodes | published_at | podcast_id, episode_id |
| charts | fetched_at | category_id, rank |

### 6. 監視とアラート

#### 6.1 予算アラートの設定

```bash
# 月額¥50,000で警告アラートを設定
gcloud billing budgets create \
  --billing-account=${BILLING_ACCOUNT_ID} \
  --display-name="bigquery-cost-alert" \
  --budget-amount=50000JPY \
  --filter-services="services/24E6-581D-38E5" \
  --threshold-rule=percent=0.5,basis=current-spend \
  --threshold-rule=percent=0.8,basis=current-spend \
  --threshold-rule=percent=1.0,basis=current-spend
```

#### 6.2 クエリログの監視

定期的にBigQueryのクエリログを確認し、高コストなクエリを特定する。

```sql
-- 直近7日間のクエリコストを確認
SELECT 
  DATE(creation_time) as date,
  COUNT(*) as query_count,
  ROUND(SUM(total_bytes_billed) / 1024 / 1024 / 1024, 2) as total_gb_billed,
  ROUND(SUM(total_bytes_billed) / 1024 / 1024 / 1024 / 1024 * 6.25 * 150, 0) as estimated_cost_jpy
FROM `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE creation_time > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
  AND job_type = 'QUERY'
  AND state = 'DONE'
GROUP BY date
ORDER BY date DESC
```

### 7. 開発・テスト時の注意事項

#### 7.1 開発環境でのテスト優先

```bash
# ❌ 本番環境で直接テスト
bq query --project_id=[PROJECT_NAME]-prod "SELECT * FROM [table_name]"

# ✅ 開発環境でテスト
bq query --project_id=[PROJECT_NAME]-dev "SELECT * FROM [table_name] LIMIT 100"
```

#### 7.2 サンプルデータでの検証

```typescript
// ❌ 全件処理でテスト
const podcasts = await getAllPodcasts();

// ✅ サンプルデータでテスト
const podcasts = await getPodcasts({ limit: 10 });
```

#### 7.3 ドライラン機能の活用

```bash
# クエリのスキャン量を事前確認（課金なし）
bq query --dry_run "SELECT * FROM episodes WHERE ..."
```

## 実装チェックリスト

新規BigQuery関連機能を実装する際は、以下をチェックする：

**✅ クエリ設計のチェック**:
- [ ] **パーティション条件が含まれているか**: `published_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)`等
- [ ] **`checkDuplicates`呼び出し時に`skipPartitionFilter: false`を明示**: パーティション条件を必ず適用
- [ ] **SELECT句に必要なカラムのみ指定**: `SELECT *`を避ける
- [ ] **LIMIT句が適切に使用されているか**: 必要以上のデータを取得しない

**✅ バッチ処理のチェック**:
- [ ] **個別処理を避け、バッチ処理を使用**: 各ポッドキャストごとに個別にクエリを実行していないか
- [ ] **バッチサイズが適切か**: 1,000件程度のバッチサイズを使用
- [ ] **バッチ処理が正しく実装されているか**: 1バッチ = 1クエリであることを確認

**✅ コスト見積もりのチェック**:
- [ ] **コスト見積もりを計算**: スキャン量 × $6.25/TB × 150円
- [ ] **想定クエリ数を確認**: バッチ数 × 1クエリ = 想定クエリ数
- [ ] **想定スキャン量を確認**: パーティション条件ありの場合、最新30日分のみスキャン

**✅ 監視とアラートのチェック**:
- [ ] **予算アラートが設定されているか**: 1日あたり¥1,000を超えた場合にアラート
- [ ] **クエリログの定期確認**: 想定クエリ数と実際のクエリ数を比較
- [ ] **スキャン量の監視**: 想定スキャン量と実際のスキャン量を比較

## 禁止事項

**❌ 絶対にやってはいけないこと**:

1. **パーティション条件なしの全テーブルスキャン**
   - 1クエリで数万円の課金が発生する可能性

2. **ループ内での個別クエリ実行**
   - N回のクエリ = N倍のコスト

3. **SELECT * の使用**
   - 不要なカラムもスキャン対象になる

4. **本番環境での無制限クエリテスト**
   - 必ずLIMIT句を使用するか、開発環境でテスト

5. **高コストエンドポイントの確認フラグ省略**
   - 誤実行で数十万円の課金リスク

## 推奨事項

**✅ 必ず実装すべきこと**:

1. **パーティション条件の追加**
   - 全クエリにパーティション条件を含める

2. **バッチ処理の実装**
   - 個別クエリをバッチ化する

3. **高コストエンドポイントの保護**
   - 確認フラグと環境変数による制御

4. **予算アラートの設定**
   - 月額予算を設定してアラートを受け取る

5. **クエリレビューの実施**
   - BigQueryを使用するコードは必ずコストの観点でレビュー

## コスト計算の目安

| スキャン量 | コスト（USD） | コスト（JPY）※150円換算 |
|-----------|-------------|----------------------|
| 1GB | $0.00625 | ¥1 |
| 10GB | $0.0625 | ¥9 |
| 100GB | $0.625 | ¥94 |
| 1TB | $6.25 | ¥938 |
| 10TB | $62.50 | ¥9,375 |
| 100TB | $625 | ¥93,750 |
| 350TB | $2,187.50 | ¥328,125 |

## 参考リンク

- [BigQuery Pricing](https://cloud.google.com/bigquery/pricing)
- [BigQuery Best Practices](https://cloud.google.com/bigquery/docs/best-practices)
- [BigQuery Query Optimization](https://cloud.google.com/bigquery/docs/best-practices-performance-overview)

