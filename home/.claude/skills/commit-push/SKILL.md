---
name: commit-push
description: 現在の変更をコミット・プッシュする。ユーザーが「コミットして」「プッシュして」「commit-push」と言ったときに使う。
version: 1.3.0
user-invocable: true
---

# Skill: コミット & プッシュ

現在の変更をコミットして GitHub にプッシュするのだ。

## 実行手順

### Step 1: リポジトリの状態を確認

現在の作業ディレクトリ（`$PWD` または会話の context から判断）で以下を実行するのだ：

```
powershell -Command "cd <REPO_PATH>; git status"
powershell -Command "cd <REPO_PATH>; git diff"
powershell -Command "cd <REPO_PATH>; git log --oneline -5"
```

### Step 2: git リポジトリが未初期化の場合

`.git` がない場合は `git init` してから GitHub に新規リポジトリを作成するのだ：

```
powershell -Command "cd <REPO_PATH>; git init"
```

`.gitignore` を先に作成して不要ファイルを除外してからステージング・コミットし、最後に `gh` で一気に作成＆プッシュするのだ：

```
powershell -Command "gh repo create <REPO_NAME> --private --source <REPO_PATH> --push"
```

- `--private` はプライベートリポジトリ（必要なら `--public` に変更）
- これ1コマンドでリモート設定＋プッシュまで完了するのだ

### Step 3: コミットメッセージを作成

`git diff` と `git log` を読んで、このリポジトリのコミットスタイルに合わせたメッセージを考えるのだ。

### Step 4: ステージングしてコミット

変更ファイルを個別に `git add` してからコミットするのだ。
PowerShell の `-m` では改行が難しいので、1行メッセージ ＋ フッターを末尾につけるのだ：

```
powershell -Command "cd <REPO_PATH>; git add <file1> <file2>; git commit -m 'summary message

Co-Authored-By: <現在のモデル名> <noreply@anthropic.com>   # 例: Claude Opus 4.8
Claude-Session: <現在のセッションURL>'"
```

- **Co-Author 名はモデル名をハードコードせず、その時点の現行モデル名を使う**（例: `Claude Opus 4.8`）。古い名前で固定しないこと。
- `Claude-Session:` 行はそのセッションの URL を入れる（harness が git 規約として注入する値を使う）。不明なら省略可。
- 機密ファイル（`.pem`, `.env` 等）は **絶対に add しない**
- 不要ファイルは先に `.gitignore` に追加してからコミットする

### Step 5: プッシュ（既存リポジトリの場合）

```
powershell -Command "cd <REPO_PATH>; git push"
```

新規リポジトリの場合は Step 2 の `gh repo create --push` で完了しているのだ。

## 注意事項

- コマンドは必ず **PowerShell** で実行する（`powershell -Command "..."` 形式）
- WSL zsh は git 操作に使わない（git user identity が未設定のため）
- リモート未設定の新規リポジトリは `gh repo create --source <path> --push` で一発なのだ
- GitHub アカウント: `bubbleShaker`
