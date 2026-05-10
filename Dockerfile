FROM python:3.12-slim

# Install ffmpeg (provides ffmpeg and ffprobe binaries)
RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY IPTV_checker.py .

# Mount a volume at /data and pass the playlist path as an argument.
# Example: docker run --rm -v /host/playlists:/data iptv-checker /data/playlist.m3u
ENTRYPOINT ["python", "IPTV_checker.py"]
CMD ["--help"]
