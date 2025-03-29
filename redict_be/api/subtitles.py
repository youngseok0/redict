from fastapi import APIRouter, HTTPException
from models.subtitle_models import SubtitleRequest, SubtitleResponse
from services.subtitle_generator import generate_subtitles_from_youtube

router = APIRouter()

@router.post("", response_model=SubtitleResponse)
def generate_srt(req: SubtitleRequest):
    try:
        srt_text = generate_subtitles_from_youtube(
            youtube_url=req.youtube_url,
            model_size=req.model_size,
            start_time=req.start_time,
            duration=req.duration
        )
        return SubtitleResponse(srt_text=srt_text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))