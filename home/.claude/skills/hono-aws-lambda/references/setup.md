# Hono on Lambda: セットアップ

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
