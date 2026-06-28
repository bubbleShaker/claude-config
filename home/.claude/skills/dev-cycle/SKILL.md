---
name: dev-cycle
description: ~/git 配下プロジェクトの開発を「Issue→実装→レビュー→PR→マージ」のオーケストレーションサイクルで進める。ユーザーが「dev-cycleで進めて」「サイクルで進めて」「Issueから実装して」と言ったときに使う。
version: 1.0.0
user-invocable: true
disable-model-invocation: true
---

# Skill: 開発オーケストレーションサイクル

`~/git/CLAUDE.md` の必須サイクルを通しで再現するのだ。要件が固まったら、以下を順に実行する。

```
Issue起票 → ブランチ → 実装 → reviewer委譲 → commit/push → PR → squashマージ → Issue確認
```

> このスキルは**サイクルの司令塔**なのだ。実際の commit/push の手順は commit-push スキルに委譲し、
> ここでは重複させない。レビューは reviewer サブエージェントに必ず委譲する。

## Step 1: Issue 起票（実装より先に）

要件を Issue で先に定義するのだ。背景・やること（チェックボックス）・受け入れ条件を書く。

```
gh issue create --title "<簡潔な要件>" --body "<背景/やること/受け入れ条件>"
```

返ってきた Issue 番号 `<n>` を以降で使う。

## Step 2: ブランチを切る

Issue に紐づくブランチで作業するのだ。命名は `feat/<n>-<短い説明>`（fix/refactor も可）。

```
git checkout -b feat/<n>-xxx
```

## Step 3: 実装（小さく刻む）

一度に大きく作らず「次の一歩」だけ実装するのだ。設計・段取りは会話ではなく PLAN.md に逃がす。

## Step 4: レビューを reviewer サブエージェントへ委譲（必須・省略禁止）

実装が一区切りしたら、**必ず** reviewer サブエージェント（Agent ツール）に差分を渡す。
観点はセキュリティ / クリーンアーキテクチャ / SOLID。**🔴 must の指摘は解消してから次へ進む**。

- 差分が大きい時は対象ブランチ・ステージ状態を伝える（reviewer は読み取り専用）。
- public リポジトリの場合は **PII・シークレットのスキャン**も依頼する（実アカウントID・絶対パス・キー）。

## Step 5: コミット & プッシュ

reviewer の 🔴 must を解消したら、コミットしてリモートへ push するのだ。
手順は commit-push スキルに揃えるのだ。**ただし commit-push は手動起動専用（`disable-model-invocation: true`）で自動では呼ばれない**。
このサイクル中は `/commit-push` を明示的に実行するか、Claude が直接 commit する場合も commit-push と同じ規約（PowerShell での git 実行・コミットメッセージ規約・機密ファイル除外）を守ること。
PR を作る前に必ず push を済ませること（push 前に `gh pr create` を走らせない）。

## Step 6: PR を出す

```
gh pr create --title "<type: 要件 (#n)>" --body "<概要 / 変更点 / レビュー結果 / Closes #n>"
```

- 本文に `Closes #<n>` を入れ、reviewer 検査済みである旨を書く。
- PR 本文末尾に Claude Code 生成のフッターを付ける。

## Step 7: squash マージして Issue 状態を確認

```
gh pr merge <pr> --squash --delete-branch
```

- ⚠️ **squash マージだと `Closes #n` が効かず Issue が OPEN のまま残ることがある**。
  マージ後に必ず確認し、残っていれば手動でクローズするのだ：

```
gh issue view <n> --json state -q .state   # CLOSED でなければ
gh issue close <n>
```

- マージ後は `git checkout master && git pull` で同期する。
- 設定リポジトリ（claude-config）等で sync が必要な場合はマージ後に反映スクリプトを実行する。

## ハマりどころ（保存版）

- **git は PowerShell で実行する**（WSL zsh は git identity 未設定）。詳細は commit-push スキル。
- **reviewer を飛ばして PR を出さない**。AI が書いた誤りを独立した目で読むのが目的なのだ。
- **Issue が後付けになった場合でも**、事後的に起票して実装との対応を明示する。
- **public リポジトリ**にコミットする前は必ず PII/シークレットをスキャンする（repo-publish スキルのパターンが流用できる）。
