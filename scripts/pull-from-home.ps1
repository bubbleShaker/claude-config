#requires -Version 7
# ~/.claude の設定をリポジトリ home/.claude へ取り込む（コミット前の同期）。
# 追跡対象ファイルだけを明示的にコピーする。機密ファイルは対象外。

$ErrorActionPreference = 'Stop'
$repoClaude = Join-Path $PSScriptRoot '..\home\.claude' | Resolve-Path
$homeClaude = Join-Path $HOME '.claude'

$files = @(
    'settings.json',
    'CLAUDE.md'
)

# ディレクトリ単位で再帰的に取り込む対象（明示列挙）。
$dirs = @(
    'agents',
    'skills'
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

foreach ($rel in $dirs) {
    # $dirs はハードコードのみ（ユーザー入力・ワイルドカード由来でない）。
    # よって削除対象は常に repo/home/.claude/<明示名> に限定される。
    $src = Join-Path $homeClaude $rel
    if (-not (Test-Path $src)) { continue }
    $dst = Join-Path $repoClaude $rel
    # home の現状で repo を丸ごと置き換える（取り込み後に git diff で公開可否を必ず確認すること）。
    # 非アトミックな「削除→コピー」を避けるため、まず temp へコピーし、成功後に入れ替える。
    $tmp = "$dst.tmp-pull"
    if (Test-Path $tmp) { Remove-Item -Path $tmp -Recurse -Force }
    Copy-Item -Path $src -Destination $tmp -Recurse -Force
    if (Test-Path $dst) { Remove-Item -Path $dst -Recurse -Force }
    Move-Item -Path $tmp -Destination $dst
    Write-Host "pulled: $rel\ (recursive)"
}
Write-Host 'done.'
