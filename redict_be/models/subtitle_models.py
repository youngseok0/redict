from pydantic import BaseModel

class SubtitleRequest(BaseModel):
    youtube_url: str
    model_size: str = "small"
    start_time: str = "00:00:00"
    duration: str = "00:00:30"

class SubtitleResponse(BaseModel):
    srt_text: str