---
name: upload-video
description: 生成済みのASMR動画をYouTubeにアップロードする。ユーザーが「アップロードして」「upload-video」「YouTubeに上げて」と言ったときに使う。
version: 1.0.0
user-invocable: true
---

# Skill: YouTube アップロード

生成済みの動画を YouTube にアップロードするのだ。

## 実行手順

### 1. メタデータの確認

直前の会話に dry-run の結果（タイトル・説明・タグ）があればそれを使うのだ。
ない場合はユーザーに確認するのだ。

動画パスは特に指定がなければ `output/final_output.mp4` を使うのだ。

### 2. アップロードコマンドを実行

以下の Python スクリプトを WSL zsh で実行するのだ（title / description / tags / video_path は実際の値で埋めること）：

```bash
wsl zsh -c "cd /mnt/c/Users/<WIN_USER>/git/asmr/asmr_pipeline && .venv/bin/python -c \"
import logging, sys
logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')
sys.path.insert(0, '.')
from pathlib import Path
from uploader.youtube import upload_video

video_id = upload_video(
    video_path=Path('VIDEO_PATH'),
    title='TITLE',
    description='DESCRIPTION',
    tags=TAGS_LIST,
    privacy_status='public',
)
print(f'URL: https://www.youtube.com/watch?v={video_id}')
\" 2>&1"
```

- バックグラウンドで実行して、完了通知を待つのだ
- 完了後は出力を読んで YouTube URL をユーザーに伝えるのだ

## 注意事項

- 環境変数 `YOUTUBE_CLIENT_ID`、`YOUTUBE_CLIENT_SECRET`、`YOUTUBE_REFRESH_TOKEN` が必要なのだ
- `privacy_status` はデフォルト `"public"` にするのだ
