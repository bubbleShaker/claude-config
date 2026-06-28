---
name: hono-aws-lambda
description: This skill should be used when the user works with Hono framework on AWS Lambda + API Gateway, builds or reviews Hono API endpoints, deploys Hono to Lambda, or asks about "Hono Lambda", "hono/aws-lambda", or Hono TypeScript API patterns.
version: 1.0.0
user-invocable: true
---

# Skill: Hono on AWS Lambda (API Gateway V2)

## 概要

TypeScript + Hono + AWS Lambda + API Gateway HTTP API (V2) のベストプラクティスガイド。

## プロジェクト構成

```
my-api/
├── src/
│   └── index.ts        # Honoアプリ + Lambdaハンドラー
├── package.json
├── tsconfig.json
└── build.mjs           # esbuildバンドルスクリプト（オプション）
```

## package.json

```json
{
  "name": "my-hono-lambda",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "build": "esbuild src/index.ts --bundle --platform=node --target=node20 --outfile=dist/index.cjs --format=cjs",
    "dev": "ts-node src/index.ts"
  },
  "dependencies": {
    "hono": "^4.0.0"
  },
  "devDependencies": {
    "@types/aws-lambda": "^8.10.145",
    "esbuild": "^0.24.0",
    "typescript": "^5.0.0"
  }
}
```

## tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "skipLibCheck": true,
    "types": ["@types/aws-lambda"]
  },
  "include": ["src/**/*"]
}
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

## ベストプラクティス

### 1. 型安全なルーティング

```typescript
import { Hono } from 'hono'

// Variables型でc.setを型安全に
type Variables = {
  userId: string
}

const app = new Hono<{ Variables: Variables }>()

app.use('/protected/*', async (c, next) => {
  c.set('userId', 'user-123') // 型チェックあり
  await next()
})
```

### 2. エラーハンドリング

```typescript
app.onError((err, c) => {
  console.error('Unhandled error:', err)
  return c.json({ error: 'Internal Server Error' }, 500)
})

app.notFound((c) => {
  return c.json({ error: 'Not Found' }, 404)
})
```

### 3. ルーターの分割（大規模APIの場合）

```typescript
// src/routes/users.ts
import { Hono } from 'hono'

const users = new Hono()
users.get('/', (c) => c.json([]))
users.get('/:id', (c) => c.json({ id: c.req.param('id') }))

export default users

// src/index.ts
import { Hono } from 'hono'
import { handle } from 'hono/aws-lambda'
import users from './routes/users'

const app = new Hono().basePath('/api')
app.route('/users', users)

export const handler = handle(app)
```

### 4. LambdaContextへのアクセス

```typescript
import { handle, LambdaEvent } from 'hono/aws-lambda'
import type { LambdaContext } from 'hono/aws-lambda'

const app = new Hono()

app.get('/context', (c) => {
  const event = c.env.event as LambdaEvent
  const lambdaContext = c.env.lambdaContext as LambdaContext
  return c.json({
    requestId: lambdaContext.awsRequestId,
    functionName: lambdaContext.functionName,
  })
})

export const handler = handle(app)
```

### 5. バイナリレスポンス（画像など）

```typescript
import { handle, defaultIsContentTypeBinary } from 'hono/aws-lambda'

export const handler = handle(app, {
  isContentTypeBinary: (contentType) => {
    if (defaultIsContentTypeBinary(contentType)) return true
    return contentType.startsWith('image/')
  },
})
```

### 6. VPC Lambda での考慮事項

- **コールドスタート対策**: esbuildでバンドルしてファイルサイズを最小化
- **タイムアウト設定**: API Gatewayの最大タイムアウトは29秒、Lambdaはそれ以上に設定
- **メモリ**: 最低256MB推奨（Node.js起動コスト）
- **環境変数**: `process.env.MY_VAR` で取得、Lambda環境変数に設定

## デプロイ手順（AWS SAM例）

```yaml
# template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Globals:
  Function:
    Timeout: 30
    MemorySize: 256
    Runtime: nodejs20.x

Resources:
  HonoApi:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: dist/
      Handler: index.handler
      VpcConfig:
        SecurityGroupIds:
          - !Ref LambdaSecurityGroup
        SubnetIds:
          - !Ref PrivateSubnet
      Events:
        Api:
          Type: HttpApi
          Properties:
            Path: /{proxy+}
            Method: ANY
```

## 注意点

- `hono/aws-lambda` は API Gateway V1 (REST API)、V2 (HTTP API)、ALB の両方に対応
- V2 (HTTP API) の方がレイテンシが低く、コストも安い → **V2推奨**
- `handle()` はイベント形式を自動判別するため、コード側での切り替えは不要
- ストリーミングが必要な場合は `streamHandle()` を使用
