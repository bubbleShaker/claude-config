#requires -Version 7
# ~/.claude の設定をリポジトリ home/.claude へ取り込む（コミット前の同期）。
# 追跡対象ファイルだけを明示的にコピーする。機密ファイルは対象外。

$ErrorActionPreference = 'Stop'
$repoClaude = Join-Path $PSScriptRoot '..\home\.claude'
$homeClaude = Join-Path $HOME '.claude'

$files = @(
    'settings.json',
    'CLAUDE.md',
    'agents\reviewer.md'
)

foreach ($rel in $files) {
    $src = Join-Path $homeClaude $rel
    if (-not (Test-Path $src)) { continue }
    $dst = Join-Path $repoClaude $rel
    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "pulled: $rel"
}
Write-Host 'done.'
