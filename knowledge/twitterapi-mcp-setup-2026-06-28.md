# twitterapi MCP server のセットアップ（正しい登録場所とキー秘匿）

X(Twitter) のポスト取得用に公式 MCP server を登録する手順と、ハマった落とし穴のメモ。
（経緯: #21 で settings.json に登録 → 読まれず失敗 → #26 で正しい場所に再登録）

## 最重要の落とし穴: MCP は settings.json には書けない

Claude Code が MCP server 定義を読む場所は **2つだけ**（公式 docs）:

| スコープ | 保存先 | 読まれる範囲 |
|---|---|---|
| user | `~/.claude.json`（トップレベル `mcpServers`） | 全プロジェクト |
| local（既定） | `~/.claude.json`（プロジェクト別） | そのプロジェクトのみ |
| project | リポジトリ直下の `.mcp.json` | そのプロジェクト（git 共有可） |

**`~/.claude/settings.json` の `mcpServers` キーは MCP 設定として読まれない。**
ここに書いても `/mcp` にも `claude mcp list` にも出ず、接続されない（#21 の失敗原因）。

> 補足: settings.json に前から残る `slack` 登録も同じ理由で死に設定（`claude mcp list`
> に出ないことを確認済み）。その撤去・移設は #26 のスコープ外として別途扱う。

## 採用パッケージ（公式）

- `@kaitoinfra/twitterapi-io-mcp-server`（運営元 kaitoinfra 公開・"Official" 明記）
- 環境変数: `TWITTERAPI_IO_API_KEY`
- 個人公開の `twitterapi-mcp`(kinhunt) もあるが、サプライチェーン安全性で公式を採用。

## 登録手順

1. https://twitterapi.io/ でサインアップし API キーを取得（クレカ不要・無料クレジットあり）。
2. **OS ユーザー環境変数**にキーを永続設定（PowerShell）:
   ```powershell
   setx TWITTERAPI_API_KEY "<取得したキー>"
   ```
   - `$env:` 代入はセッション限りで消えるので不可。
   - 設定後は Claude Code / シェルを再起動（`setx` は既存プロセスに反映されない）。
3. user スコープで登録（**リポジトリルートから** `scripts/setup-mcp-twitterapi.ps1` を実行）:
   ```powershell
   & scripts/setup-mcp-twitterapi.ps1   # cwd がリポジトリルートである前提
   ```
   実体はこのコマンド:
   ```powershell
   claude mcp add twitterapi --scope user --transport stdio `
     --env 'TWITTERAPI_IO_API_KEY=${TWITTERAPI_API_KEY}' `
     -- npx -y '@kaitoinfra/twitterapi-io-mcp-server@0.1.2'
   ```
4. `claude mcp list` で `twitterapi ... ✔ Connected` を確認。

## キーを平文で残さない仕組み

- `~/.claude.json` の env 値は `"TWITTERAPI_IO_API_KEY": "${TWITTERAPI_API_KEY}"` という
  **参照のまま**保存され、Claude Code が起動時に OS 環境変数から展開する。
- よって平文キーはどのファイルにも残らず、OS のユーザー環境変数にのみ存在する。
- `~/.claude.json` 自体も git 管理外（claude-config の追跡対象は home/.claude/ のみ）。
- 変数名のマッピング: 公式 server は `TWITTERAPI_IO_API_KEY` を要求するが、既存の
  `TWITTERAPI_API_KEY` を `${...}` で流用しているので env の再設定は不要。

## 動作確認済み（2026-06-28）

- `claude mcp list` → `twitterapi ... ✔ Connected`
- `search_tweets`（query: `from:elonmusk`, queryType: `Latest`）で実ツイートが
  id/text/likeCount 付きで返却。
- 提供ツール（12個）: search_tweets / get_user_info / get_user_about /
  get_user_followers / get_user_followings / get_user_last_tweets / get_user_mentions /
  get_tweets_by_ids / get_tweet_replies / get_tweet_quotes / get_tweet_retweeters / get_trends。
  注: `search_tweets` は `queryType`（`Latest` | `Top`）が必須。

## ハマりどころ

- 環境変数が未設定だと展開結果が空になり、接続はしてもツール呼び出しでキー不正になる。
- 「再起動した」つもりでも親ランチャーが古い環境を保持していると新プロセスに env が乗らない。
  `$env:TWITTERAPI_API_KEY.Length` が 0 でないことを確認すると確実。
