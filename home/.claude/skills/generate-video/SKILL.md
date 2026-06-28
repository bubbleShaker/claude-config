---
name: generate-video
description: ASMRパイプラインで動画を dry-run モードで生成する。ユーザーが「動画を生成して」「generate-video」と言ったときに使う。
disable-model-invocation: true
---

# Skill: ASMR動画生成 (dry-run)

ASMRパイプラインを dry-run モードで実行して動画を生成するのだ。YouTubeにはアップロードせず、ローカルに保存するのだ。

## 実行手順

以下のコマンドを WSL zsh で実行するのだ：

```bash
wsl zsh -c "cd /mnt/c/Users/<WIN_USER>/git/asmr/asmr_pipeline && .venv/bin/python main.py --dry-run 2>&1"
```

- バックグラウンドで実行して、完了通知を待つのだ
- 完了後は出力ファイルを読んで結果（タイトル・動画パス）をユーザーに伝えるのだ
- 生成された動画は `asmr_pipeline/output/final_output.mp4` に保存されるのだ

## 注意事項

- 環境変数 `FREESOUND_API_KEY`、`PEXELS_API_KEY`、`ANTHROPIC_API_KEY` が必要なのだ
- Freesound の filter 構文は `-tag:voice` 形式（Lucene の禁止プレフィックス）を使うのだ
