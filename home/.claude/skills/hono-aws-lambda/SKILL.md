---
name: hono-aws-lambda
description: This skill should be used when the user works with Hono framework on AWS Lambda + API Gateway, builds or reviews Hono API endpoints, deploys Hono to Lambda, or asks about "Hono Lambda", "hono/aws-lambda", or Hono TypeScript API patterns.
version: 2.0.1
user-invocable: true
---

# Skill: Hono on AWS Lambda (API Gateway V2)

## 概要

TypeScript + Hono + AWS Lambda + API Gateway HTTP API (V2) のベストプラクティスガイド。
詳細は必要に応じて下記 `references/` を読むのだ。

## プロジェクト構成

```
my-api/
├── src/
│   └── index.ts        # Honoアプリ + Lambdaハンドラー
├── package.json        # build スクリプト(esbuild)を含む
└── tsconfig.json
```

## 基本実装パターン

```typescript
import { Hono } from 'hono'
import { handle } from 'hono/aws-lambda'
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'

// Env型定義（Lambdaのバインディング・変数）
type Bindings = {
  // 環境変数はprocess.envから取得するため基本不要
}

const app = new Hono<{ Bindings: Bindings }>()

// ミドルウェア
app.use('*', logger())
app.use('/api/*', cors())

// ルーティング
app.get('/', (c) => c.json({ status: 'ok' }))

// Lambdaハンドラーとしてエクスポート
export const handler = handle(app)
```

## 注意点（要点）

- `hono/aws-lambda` は API Gateway V1 (REST API)、V2 (HTTP API)、ALB の両方に対応
- V2 (HTTP API) の方がレイテンシが低く、コストも安い → **V2推奨**
- `handle()` はイベント形式を自動判別するため、コード側での切り替えは不要
- ストリーミングが必要な場合は `streamHandle()` を使用

## 詳細リファレンス

必要になったときだけ読むのだ（token 節約のため SKILL.md からは分離している）。

| ファイル | 内容 |
|---|---|
| `references/setup.md` | `package.json` / `tsconfig.json`（esbuild バンドル設定） |
| `references/patterns.md` | 型安全ルーティング・エラーハンドリング・ルーター分割・LambdaContext・バイナリ応答・VPC考慮 |
| `references/deploy.md` | AWS SAM テンプレート例・ビルド手順 |
