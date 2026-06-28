# claude-config

私の Claude Code 環境（`~/.claude`）の設定をバージョン管理するリポジトリなのだ。

[Qiita「Claude Code 使用の7つの誤り」](https://qiita.com/tehito/items/356e5f1dba112a075be1) の改善策を反映した「引き算」志向の構成を維持する。

## 何を管理するか

`home/.claude/` 配下が source of truth。**設定ファイルだけ**を置き、機密・会話履歴は一切含めない。

| パス | 内容 |
|---|---|
| `home/.claude/settings.json` | モデル/テーマ/hooks/MCP などの設定 |
| `home/.claude/CLAUDE.md` | global ガイドライン（Vibe Coding + 運用方針） |
| `home/.claude/agents/` | サブエージェント定義（例: `reviewer.md`） |
| `home/.claude/skills/` | ユーザースキル定義（`SKILL.md` 一式）。ディレクトリ単位で再帰同期する |

> project 側の `~/git/CLAUDE.md`（オーケストレーション方針）は別リポジトリ
> [`orchestration-guidelines`](https://github.com/bubbleShaker/orchestration-guidelines) で管理しているのでここには含めない。

機密ファイル（`.credentials.json` / `history.jsonl` / `sessions/` 等）は
そもそも `home/.claude/` に置かず、`.gitignore` でも多層防御で除外している。

> ⚠️ このリポジトリは **public**。`skills/` には実コマンドが入るため、
> 取り込み・編集時に実アカウントID・絶対パス・ユーザー名などの PII を
> プレースホルダー（`<WIN_USER>` 等）へ置換してからコミットすること。

## 同期

PowerShell スクリプトで明示的にコピーする（symlink は Windows で不安定なため不採用）。

```powershell
# リポジトリ → ~/.claude へ反映（設定を適用する）
./scripts/sync-to-home.ps1

# ~/.claude → リポジトリへ取り込む（手で設定を変えた後にコミットする前）
./scripts/pull-from-home.ps1
```

両スクリプトとも、コピー対象は上表のファイルに限定している。
