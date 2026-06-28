---
name: repo-publish
description: プライベートリポジトリを安全にpublicにする。機密情報のスキャン・履歴書き換え・public化を一連で行う。ユーザーが「publicにして」「repo-publish」「リポジトリを公開して」と言ったときに使う。
version: 1.0.0
user-invocable: true
---

# Skill: リポジトリ安全公開

プライベートリポジトリを public にする前に、機密情報の漏洩を検出・除去し、git 履歴ごと書き換えてから公開するのだ。

## 前提確認

- `git-filter-repo` が必要なのだ。なければ `scoop install git-filter-repo` でインストールするのだ
- `python` が必要なのだ。なければ `scoop install python` でインストールするのだ
- `gh` CLI が必要なのだ（GitHub 操作に使う）

## Step 1: リポジトリの特定

ユーザーが対象リポジトリを指定していない場合は、現在の作業ディレクトリかリモート URL から特定するのだ。

```powershell
Set-Location <REPO_PATH>
git remote -v
```

## Step 2: 機密情報をスキャン

以下のパターンを検索するのだ（`node_modules`・`.git`・`dist`・`cdk.out` は除外）：

```powershell
# AWS アクセスキー（実キーのパターン）
git grep -rn "AKIA[A-Z0-9]{16}" -- . ":(exclude)*/node_modules/*"

# 実際の値が入っていそうなパターンを広く検索
git grep -rn -i -E "(aws_secret|password\s*=|token\s*=|api_key\s*=|private_key)" `
  -- . ":(exclude)*/node_modules/*" ":(exclude)*/dist/*"
```

git 履歴にも含まれているか確認するのだ：

```powershell
git log -p --all -S "<検出した値>" --oneline | Select-Object -First 20
```

## Step 3: 問題箇所を整理してユーザーに報告

スキャン結果をもとに以下を分類して報告するのだ：

| 重要度 | 内容 | 例 |
|---|---|---|
| 🔴 必須対応 | 実際のシークレット・アクセスキー | `AKIA...`、`aws_secret_access_key` |
| 🔴 必須対応 | AWSアカウントID（12桁数字） | `123456789012` |
| 🟡 要検討 | ライブ環境の URL・エンドポイント | CloudFront URL、API Gateway URL |
| 🟡 要検討 | リソース固有 ID | API Gateway ID、Integration ID |
| ✅ 問題なし | プレースホルダー・テンプレート記述 | `<ACCOUNT_ID>`、`your-bucket-name` |

問題が見つかった場合はユーザーに確認し、修正対象の値と置換後の値を決めてから進めるのだ。

## Step 4: ファイルを修正

各ファイルの実値をプレースホルダーに置き換えるのだ。

**`infra/bin/infra.ts` にアカウントIDがある場合：**

```typescript
// Before
const env = { account: '123456789012', region: 'ap-northeast-1' };

// After（CDK_DEFAULT_ACCOUNT は AWS CLI の設定から自動取得）
const env = {
  account: process.env.CDK_DEFAULT_ACCOUNT,
  region: process.env.CDK_DEFAULT_REGION ?? 'ap-northeast-1',
};
```

**ドキュメント・CLAUDE.md の場合：**
実値を `<YOUR_ACCOUNT_ID>`、`<YOUR_API_ID>` などのプレースホルダーに置き換えるのだ。

修正後にコミットするのだ：

```powershell
git add <修正したファイル>
git commit -m "security: 機密情報をコードから除去"
```

## Step 5: git 履歴を書き換え

置換ルールファイルを作成するのだ（実値 `==>` 置換後の形式）：

```powershell
@"
123456789012==>YOUR_ACCOUNT_ID
actual-cloudfront-domain.cloudfront.net==>YOUR_CLOUDFRONT_DOMAIN
actual-api-id==>YOUR_API_ID
"@ | Out-File -FilePath "filter-replacements.txt" -Encoding utf8 -NoNewline
```

`git filter-repo` で全履歴から一括置換するのだ：

```powershell
$filterRepo = "C:\Users\<WIN_USER>\scoop\apps\git-filter-repo\current\git-filter-repo"
python $filterRepo --replace-text filter-replacements.txt --force
```

> **注意**：`git filter-repo` は実行後に `origin` リモートを自動削除するのだ（誤 push 防止のため）。後で再登録する。

履歴からきれいに消えたか確認するのだ：

```powershell
git log -p --all -S "実値" --oneline | Select-Object -First 5
# 何も出なければ OK
```

一時ファイルを削除するのだ：

```powershell
Remove-Item filter-replacements.txt
```

## Step 6: origin を再登録して force push

`git filter-repo` が削除した origin を再登録するのだ：

```powershell
git remote add origin https://github.com/<OWNER>/<REPO>.git
git push --force origin master   # ブランチ名が main の場合は main
```

> force push はリモートの履歴を上書きする。リポジトリがまだ private であることを必ず確認してから実行するのだ。

## Step 7: public に変更

```powershell
gh repo edit <OWNER>/<REPO> --visibility public --accept-visibility-change-consequences
```

完了を確認するのだ：

```powershell
gh repo view <OWNER>/<REPO> --json visibility -q .visibility
# → PUBLIC
```

## 注意事項

- **アクセスキー（`AKIA...`）が見つかった場合は public 化前に必ず AWS コンソールでキーを無効化・削除すること**。履歴から消しても、一度 push されたキーは漏洩したとみなすのだ
- コミット数が多いリポジトリでは `git filter-repo` に時間がかかる場合があるのだ
- 複数のブランチがある場合は全ブランチを確認・force push するのだ
- GitHub Actions のシークレットや環境変数は別途確認するのだ
