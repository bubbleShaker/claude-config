#requires -Version 7
# twitterapi MCP server を user スコープで登録する（公式 @kaitoinfra 版）。
#
# なぜスクリプトか:
#   Claude Code の MCP 定義は ~/.claude.json(user/local) か .mcp.json(project) にしか書けない。
#   settings.json の mcpServers は読まれない（#26 で判明）。~/.claude.json は git 管理外なので、
#   「登録を再現する手順」を claude-config にコミットする形で構成管理する。
#   このスクリプト自体に秘密は含めない（OS 環境変数 TWITTERAPI_API_KEY を ${...} で参照する）。

$ErrorActionPreference = 'Stop'

# 事前条件: OS のユーザー環境変数 TWITTERAPI_API_KEY に TwitterAPI.io のキーを設定しておく。
#   setx TWITTERAPI_API_KEY "<your key>"   （設定後は Claude Code/シェルを再起動）
$key = [Environment]::GetEnvironmentVariable('TWITTERAPI_API_KEY', 'User')
if (-not $key) {
    throw 'User env var TWITTERAPI_API_KEY が未設定。setx TWITTERAPI_API_KEY "<key>" で設定してから再実行する。'
}

# 冪等化: 既存登録を消してから追加する（無ければ無視）。
try { claude mcp remove twitterapi --scope user 2>$null } catch {}

# 公式パッケージを user スコープで登録。
# env 値は ${TWITTERAPI_API_KEY} 参照のまま ~/.claude.json に保存され、Claude Code が起動時に展開する。
# → 平文キーはどのファイルにも残らない（OS 環境変数にのみ存在）。
# 公式 server が要求する変数名は TWITTERAPI_IO_API_KEY なので、既存 TWITTERAPI_API_KEY をマッピングする。
claude mcp add twitterapi --scope user --transport stdio `
    --env 'TWITTERAPI_IO_API_KEY=${TWITTERAPI_API_KEY}' `
    -- npx -y '@kaitoinfra/twitterapi-io-mcp-server@0.1.2'

if ($LASTEXITCODE -ne 0) { throw "claude mcp add に失敗した (exit $LASTEXITCODE)。" }

# 登録直後にヘルスチェックを表示して、接続失敗の見落としを防ぐ。
Write-Host 'registered. health check:'
claude mcp list | Select-String -Pattern 'twitterapi'
Write-Host 'done. 上に `twitterapi ... ✔ Connected` が出ていれば成功。'
