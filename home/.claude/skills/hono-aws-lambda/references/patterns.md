# Hono on Lambda: ベストプラクティス

## 1. 型安全なルーティング

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

## 2. エラーハンドリング

```typescript
app.onError((err, c) => {
  console.error('Unhandled error:', err)
  return c.json({ error: 'Internal Server Error' }, 500)
})

app.notFound((c) => {
  return c.json({ error: 'Not Found' }, 404)
})
```

## 3. ルーターの分割（大規模APIの場合）

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

## 4. LambdaContextへのアクセス

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

## 5. バイナリレスポンス（画像など）

```typescript
import { handle, defaultIsContentTypeBinary } from 'hono/aws-lambda'

export const handler = handle(app, {
  isContentTypeBinary: (contentType) => {
    if (defaultIsContentTypeBinary(contentType)) return true
    return contentType.startsWith('image/')
  },
})
```

## 6. VPC Lambda での考慮事項

- **コールドスタート対策**: esbuildでバンドルしてファイルサイズを最小化
- **タイムアウト設定**: API Gatewayの最大タイムアウトは29秒、Lambdaはそれ以上に設定
- **メモリ**: 最低256MB推奨（Node.js起動コスト）
- **環境変数**: `process.env.MY_VAR` で取得、Lambda環境変数に設定
