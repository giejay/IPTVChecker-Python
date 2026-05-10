#!/bin/bash
set -e

if [ -n "$CRON_SCHEDULE" ]; then
    echo "Starting IPTV Checker in cron mode: $CRON_SCHEDULE"

    # Persist current environment so cron jobs inherit all env vars
    printenv | while IFS='=' read -r name value; do
        printf 'export %s=%q\n' "$name" "$value"
    done > /etc/cron_env.sh

    # Create wrapper script that sources the env and runs the checker
    cat > /app/run_checker.sh << 'EOF'
#!/bin/bash
source /etc/cron_env.sh
echo "[$(date)] Starting IPTV check..."
python /app/IPTV_checker.py
echo "[$(date)] IPTV check complete."
EOF
    chmod +x /app/run_checker.sh

    # Install crontab (trailing newline is required by cron)
    printf '%s /app/run_checker.sh >> /proc/1/fd/1 2>&1\n' "$CRON_SCHEDULE" \
        > /etc/cron.d/iptv-checker
    chmod 0644 /etc/cron.d/iptv-checker
    crontab /etc/cron.d/iptv-checker

    # Optionally run immediately on container start before entering cron loop
    if [ "${CRON_RUN_ON_START:-false}" = "true" ]; then
        echo "Running initial check on startup..."
        python /app/IPTV_checker.py
    fi

    echo "Cron scheduler active. Schedule: $CRON_SCHEDULE"
    exec cron -f
else
    exec python /app/IPTV_checker.py "$@"
fi
