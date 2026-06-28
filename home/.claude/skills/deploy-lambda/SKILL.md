---
name: deploy-lambda
description: ASMRパイプラインを AWS Lambda にデプロイする。ユーザーが「Lambdaにデプロイして」「deploy-lambda」と言ったときに使う。
version: 1.0.0
user-invocable: true
disable-model-invocation: true
---

# Skill: Lambda デプロイ

ASMRパイプラインの最新コードをビルドして AWS Lambda にデプロイするのだ。

## 実行手順

### Step 1: zip ビルド

以下のコマンドを WSL zsh で実行するのだ：

```bash
wsl zsh -c "cd /mnt/c/Users/<WIN_USER>/git/asmr/asmr_pipeline && bash scripts/build_lambda.sh 2>&1"
```

### Step 2: Lambda にデプロイ

ビルド成功後、続けてデプロイするのだ：

```bash
wsl zsh -c "cd /mnt/c/Users/<WIN_USER>/git/asmr/asmr_pipeline && bash scripts/deploy.sh 2>&1"
```

- 両コマンドは **順番に**（ビルド完了後にデプロイ）実行するのだ
- 完了後はデプロイ結果（関数名・リージョン）をユーザーに伝えるのだ

## デプロイ先

- **関数名:** `asmr-pipeline`
- **リージョン:** `ap-northeast-1`
- **スケジュール:** 08:00 / 16:00 / 00:00 JST (3回/日)

## 注意事項

- AWS 認証情報が WSL 環境に設定済みであること
- `lambda.zip` は `asmr_pipeline/` 直下に生成される（約23MB）
- ffmpeg バイナリは `asmr_pipeline/bin/` にキャッシュされるのだ
