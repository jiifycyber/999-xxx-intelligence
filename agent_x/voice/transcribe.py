from pathlib import Path
import subprocess
import tempfile
import wave
import array
import math
import re

MODEL = Path(__file__).resolve().parent / "models/ggml-small.en.bin"

def transcribe(audio: bytes) -> str:
    if not audio or len(audio) > 8_000_000:
        raise ValueError("Invalid audio recording size")

    if not MODEL.is_file():
        raise RuntimeError("Whisper model not found")

    with tempfile.TemporaryDirectory(prefix="agent_x_voice_") as folder:
        folder = Path(folder)
        original = folder / "recording.bin"
        wav = folder / "recording.wav"
        original.write_bytes(audio)

        subprocess.run(
            [
                "/opt/homebrew/bin/ffmpeg",
                "-nostdin", "-v", "error", "-y",
                "-i", str(original),
                "-t", "30",
                "-ar", "16000",
                "-ac", "1",
                "-c:a", "pcm_s16le",
                str(wav),
            ],
            check=True,
            capture_output=True,
            timeout=45,
        )

        with wave.open(str(wav), "rb") as f:
            frames = f.readframes(f.getnframes())

        if len(frames) < 16000:
            raise ValueError("Recording too short")

        samples = array.array("h")
        samples.frombytes(frames)
        rms = math.sqrt(sum(v*v for v in samples) / len(samples))
        if rms < 100:
            raise ValueError("No clear speech detected")

        import urllib.request
        import json
        try:
            boundary = "AgentXBoundary"
            body = ("--"+boundary+"\r\nContent-Disposition: form-data; name=\"file\"; filename=\"recording.wav\"\r\nContent-Type: audio/wav\r\n\r\n").encode()+wav.read_bytes()+("\r\n--"+boundary+"\r\nContent-Disposition: form-data; name=\"response_format\"\r\n\r\njson\r\n--"+boundary+"--\r\n").encode()
            req = urllib.request.Request("http://127.0.0.1:8080/inference",data=body,headers={"Content-Type":"multipart/form-data; boundary="+boundary},method="POST")
            with urllib.request.urlopen(req,timeout=45) as response:
                text = json.loads(response.read().decode())["text"].strip()
            if text:
                return re.sub(r"\s+"," ",text)[:12000]
        except Exception:
            pass

        result = subprocess.run(
            [
                "/opt/homebrew/bin/whisper-cli",
                "-m", str(MODEL),
                "-f", str(wav),
                "-l", "en",
                "-nt",
            ],
            capture_output=True,
            text=True,
            timeout=120,
            check=True,
        )

        text = result.stdout.strip()
        text = re.sub(r"\s+", " ", text)

        if not text:
            raise ValueError("No speech recognized")

        return text[:12000]
