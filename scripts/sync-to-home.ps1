#requires -Version 7
# リポジトリの home/.claude を ~/.claude へ反映する（設定を適用）。
# 追跡対象ファイルだけを明示的にコピーし、~/.claude の機密ファイルには触れない。

$ErrorActionPreference = 'Stop'
$repoClaude = Join-Path $PSScriptRoot '..\home\.claude' | Resolve-Path
$homeClaude = Join-Path $HOME '.claude'

# コピー対象（相対パス）を明示列挙する。ワイルドカードで巻き込まない。
$files = @(
    'settings.json',
    'CLAUDE.md',
    'agents\reviewer.md'
)

foreach ($rel in $files) {
    $src = Join-Path $repoClaude $rel
    if (-not (Test-Path $src)) { continue }
    $dst = Join-Path $homeClaude $rel
    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "applied: $rel"
}
Write-Host 'done.'
