from pytubefix import YouTube
import whisper
import os
from pathlib import Path
from core.config import settings
import uuid
import subprocess
import datetime

def download_audio_clip_ytdlp(video_url, start="00:00:00,000", duration="00:00:30,000", output_dir="."):
  output_path = Path(output_dir) / f"{uuid.uuid4()}.mp3"
  
  # Format times for yt-dlp (which uses periods for milliseconds)
  start_ytdlp = start.replace(",", ".")
  end_ytdlp = _add_time(start, duration).replace(",", ".")
  
  # Format times for ffmpeg (which uses periods for milliseconds)
  start_ffmpeg = start.replace(",", ".")
  duration_parts = duration.split(",")
  duration_ffmpeg = f"{duration_parts[0]}.{duration_parts[1]}" if "," in duration else duration
  
  command = [
    "yt-dlp",
    "-x", "--audio-format", "mp3",
    "--download-sections", f"*{start_ytdlp}-{end_ytdlp}",
    "--postprocessor-args", f"-ss {start_ffmpeg} -t {duration_ffmpeg}",
    "-o", str(output_path),
    video_url
  ]

  subprocess.run(command, check=True)
  return str(output_path)

def _add_time(start, duration):
  fmt = "%H:%M:%S,%f"
  # Convert input formats if they don't contain milliseconds
  if "," not in start:
    start = f"{start},000"
  if "," not in duration:
    duration = f"{duration},000"
  
  # Parse the start time
  s = datetime.datetime.strptime(start, fmt)
  
  # Split duration into time and milliseconds
  duration_parts = duration.split(",")
  time_part = datetime.datetime.strptime(duration_parts[0], "%H:%M:%S")
  millis_part = int(duration_parts[1][:3])
  
  # Calculate duration as timedelta
  d = datetime.timedelta(
    hours=time_part.hour,
    minutes=time_part.minute, 
    seconds=time_part.second,
    milliseconds=millis_part
  )
  
  # Add duration to start time
  result = s + d
  
  # Format with milliseconds (only keep first 3 digits)
  return result.strftime("%H:%M:%S,%f")[:-3]

def format_srt_time(seconds):
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    sec = int(seconds % 60)
    millis = int((seconds - int(seconds)) * 1000)
    return f"{hours:02}:{minutes:02}:{sec:02},{millis:03}"

def transcribe_audio_to_srt_text(audio_path, model_size="small") -> str:
    model = whisper.load_model(model_size)
    result = model.transcribe(audio_path)

    srt_lines = []
    for i, segment in enumerate(result["segments"]):
        start = format_srt_time(segment["start"])
        end = format_srt_time(segment["end"])
        text = segment["text"]

        srt_lines.append(f"{i+1}\n{start} --> {end}\n{text}\n")

    os.remove(audio_path)  # cleanup
    return "\n".join(srt_lines)

def generate_subtitles_from_youtube(youtube_url: str, model_size: str = "small", start_time: str = "00:00:00,000", duration: str = "00:00:30,000") -> str:
    audio_path = download_audio_clip_ytdlp(youtube_url, start_time, duration, settings.AUDIO_TEMP_DIR)
    srt_text = transcribe_audio_to_srt_text(audio_path, model_size)
    return srt_text