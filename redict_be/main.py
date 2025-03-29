# app/
# ├── main.py
# ├── core/
# │   └── config.py
# ├── api/
# │   ├── __init__.py
# │   ├── download.py             # 파일 다운로드
# │   └── subtitles.py            # SRT 생성 검색 API
# ├── models/
# │   ├── download_models.py
# │   └── subtitle_models.py      # 요청/응답 모델
# ├── services/
# │   ├── file_downloader.py
# │   └── subtitle_generator.py   # SRT 생성 기능
# ├── static/
# │   ├── downloaded_files/       # 계속 들어가는 파일
# │   └── subtitles/              # 생성된 SRT 파일
# └── requirements.txt



# main.py 추가 mount
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api import download, subtitles
from core.config import settings
from fastapi.staticfiles import StaticFiles
from pathlib import Path

app = FastAPI(title="Download API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

Path(settings.DOWNLOAD_DIR).mkdir(parents=True, exist_ok=True)
Path(settings.AUDIO_TEMP_DIR).mkdir(parents=True, exist_ok=True)

app.mount("/files", StaticFiles(directory=settings.DOWNLOAD_DIR), name="files")

# app.include_router(download.router, prefix="/api/download", tags=["Download"])
app.include_router(subtitles.router, prefix="/api/subtitles", tags=["Subtitles"])
