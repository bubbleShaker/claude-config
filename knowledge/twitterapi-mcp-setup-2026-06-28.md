# twitterapi MCP server のセットアップ（API キーを git に置かない方法）

Issue #21 で X(Twitter) ポスト取得用に `twitterapi` MCP server を登録した。
その際の「API キーを git 管理ファイルに平文で入れない」仕組みのメモ。

## 仕組み

`home/.claude/settings.json` の `mcpServers.twitterapi.env` には、キー本体ではなく
**環境変数参照** `${TWITTERAPI_API_KEY}` だけを書く。

```jsonc
"twitterapi": {
  "command": "npx",
  "args": ["-y", "twitterapi-mcp@1.0.0"], // バージョン pin（サプライチェーン対策・再現性）
  "env": {
    "TWITTERAPI_API_KEY": "${TWITTERAPI_API_KEY}" // 実キーはOS環境変数から注入
  }
}
```

Claude Code は MCP 設定の `env` 値で `${VAR}` を OS 環境変数から展開する。
よって git に残るのは参照文字列だけで、キー実体はリポジトリに入らない。

## 別マシンで使うとき（必須の事前作業）

1. https://twitterapi.io/ でサインアップし API キーを取得（クレカ不要・無料クレジットあり）。
2. **ユーザー環境変数**に永続設定する（PowerShell）:
   ```powershell
   setx TWITTERAPI_API_KEY "<取得したキー>"
   ```
   - `$env:` への代入はそのセッション限りで消えるので不可。`setx` で永続化する。
   - キーをコマンド履歴に残したくなければ `sysdm.cpl` のGUIから手入力でもよい。
3. **Claude Code を再起動**する。`setx` は既存プロセスに反映されないため、
   再起動して初めて `${TWITTERAPI_API_KEY}` が展開される。
4. `/mcp` で `twitterapi` が connected になり、`search_tweets` 等が使えることを確認。

## ハマりどころ

- 環境変数が未設定だと展開結果が空文字になり、MCP が**静かに失敗**する（接続はするがキー不正）。
- 「再起動した」つもりでも親ランチャーが古い環境を保持していると、新プロセスに環境変数が
  乗らないことがある。`$env:TWITTERAPI_API_KEY.Length` で 0 でないことを確認すると確実。

## 動作確認済み（2026-06-28）

`search_tweets`（query: `from:elonmusk`）で実ツイートが id/text/likeCount 付きで返ることを確認。
提供ツール: get_user_by_username / get_user_by_id / get_user_tweets / search_tweets /
get_tweet_by_id / get_tweet_replies / get_user_followers / get_user_following /
search_users / login_user / create_tweet。
