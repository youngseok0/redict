from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DOWNLOAD_DIR: str = "static/downloaded_files"
    SUBTITLE_DIR: str = "static/subtitles"  # unused now
    AUDIO_TEMP_DIR: str = "static/tmp"

    class Config:
        env_file = "redict_venv"

settings = Settings()