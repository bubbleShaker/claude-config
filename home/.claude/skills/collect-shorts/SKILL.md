---
name: collect-shorts
description: YouTube Shorts の楽曲・ボカロ・バイラルサウンドを収集する。ユーザーが「Shortsを収集して」「collect-shorts」「ボカロ収集して」と言ったときに使う。
version: 1.0.0
user-invocable: true
---

# Skill: YouTube Shorts 楽曲収集

YouTube Shorts のトレンド楽曲・ボカロ曲・バイラルサウンドを収集して MP3 サンプルを生成するのだ。

## 実行コマンド

```
wsl zsh -c 'export PATH="$PATH:$HOME/.local/bin" && cd /mnt/c/Users/<WIN_USER>/git/youtube_short_scraping && python3 collect.py <ARGS>'
```

`<ARGS>` をユーザーの指示から組み立てて実行するのだ。
`<WIN_USER>` は Windows のユーザー名に読み替えるのだ（WSL からは `/mnt/c/Users/<WIN_USER>/...` で Windows 側 git を参照する）。

## 引数の対応

| ユーザーの指示 | 引数 |
|---|---|
| 引数なし | （なし、全プリセットで 10 曲） |
| ボカロ | `--preset vocaloid` |
| バイラル / viral | `--preset viral` |
| jpop / J-POP | `--preset jpop` |
| N曲 | `--max N` |
| "〇〇" を検索 | `--query "〇〇"` |
| 最大Ns以下 | `--max-duration N` |

複数の引数は組み合わせ可能なのだ。

## プリセット一覧

- `viral` — バイラルサウンド（MONTAGEM HIKARI、phonk 等）
- `vocaloid` — ボカロ曲（surge、ハッピーシンセサイザー 等）
- `jpop` — J-POP Shorts トレンド
- `all`（デフォルト）— 全プリセット

## 実行例

```bash
# デフォルト（全プリセット 10 曲）
wsl zsh -c 'export PATH="$PATH:$HOME/.local/bin" && cd /mnt/c/Users/<WIN_USER>/git/youtube_short_scraping && python3 collect.py'

# ボカロ 20 曲
wsl zsh -c 'export PATH="$PATH:$HOME/.local/bin" && cd /mnt/c/Users/<WIN_USER>/git/youtube_short_scraping && python3 collect.py --preset vocaloid --max 20'

# 特定曲名で検索
wsl zsh -c 'export PATH="$PATH:$HOME/.local/bin" && cd /mnt/c/Users/<WIN_USER>/git/youtube_short_scraping && python3 collect.py --query "MONTAGEM HIKARI" --query "surge ボカロ"'

# バイラル 5 曲
wsl zsh -c 'export PATH="$PATH:$HOME/.local/bin" && cd /mnt/c/Users/<WIN_USER>/git/youtube_short_scraping && python3 collect.py --preset viral --max 5'
```

## 出力先

`/mnt/c/Users/<WIN_USER>/git/youtube_short_scraping/trending_samples/` に MP3 サンプルが保存されるのだ。
