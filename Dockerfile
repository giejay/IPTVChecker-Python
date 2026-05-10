FROM python:3.12-slim

# Install ffmpeg (provides ffmpeg and ffprobe binaries) and cron
RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg cron \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY IPTV_checker.py .
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Mount a volume at /data and pass the playlist path as an argument.
# Example (one-shot): docker run --rm -v /host/playlists:/data iptv-checker /data/playlist.m3u
# Example (cron):     set CRON_SCHEDULE env var, e.g. "0 6 * * *" for daily at 06:00
ENTRYPOINT ["/docker-entrypoint.sh"]