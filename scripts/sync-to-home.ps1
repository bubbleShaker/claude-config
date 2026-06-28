#requires -Version 7
# リポジトリの home/.claude を ~/.claude へ反映する（設定を適用）。
# 追跡対象ファイルだけを明示的にコピーし、~/.claude の機密ファイルには触れない。

$ErrorActionPreference = 'Stop'
$repoClaude = Join-Path $PSScriptRoot '..\home\.claude' | Resolve-Path
$homeClaude = Join-Path $HOME '.claude'

# コピー対象（相対パス）を明示列挙する。ワイルドカードで巻き込まない。
$files = @(
    'settings.json',
    'CLAUDE.md'
)

# ディレクトリ単位で再帰コピーする対象（明示列挙）。配下を丸ごと反映する。
$dirs = @(
    'agents',
    'skills'
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

foreach ($rel in $dirs) {
    # $dirs はハードコードのみ（ユーザー入力・ワイルドカード由来でない）。
    # よって削除対象は常に ~/.claude/<明示名> に限定され、home の他ファイルは巻き込まない。
    $src = Join-Path $repoClaude $rel
    if (-not (Test-Path $src)) { continue }
    $dst = Join-Path $homeClaude $rel
    # repo を source of truth として丸ごと置き換える（home 側で消したスキルは復活しない）。
    # 非アトミックな「削除→コピー」を避けるため、まず temp へコピーし、成功後に入れ替える。
    # コピーが途中失敗しても既存の $dst は無傷で残る。
    $tmp = "$dst.tmp-sync"
    if (Test-Path $tmp) { Remove-Item -Path $tmp -Recurse -Force }
    Copy-Item -Path $src -Destination $tmp -Recurse -Force
    if (Test-Path $dst) { Remove-Item -Path $dst -Recurse -Force }
    Move-Item -Path $tmp -Destination $dst
    Write-Host "applied: $rel\ (recursive)"
}
Write-Host 'done.'
