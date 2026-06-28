# Hono on Lambda: デプロイ（AWS SAM 例）

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

## ビルド

`package.json` の `build` スクリプト（esbuild バンドル）で `dist/index.cjs` を生成してから
`CodeUri: dist/` で参照する。バンドルによりコールドスタートを抑えられる。
詳細は [setup.md](setup.md) を参照。
