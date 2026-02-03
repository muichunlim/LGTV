#!/usr/bin/env bash
set -euo pipefail

# 切换到脚本所在目录（防止被 cron / workflow 从别处调用）
cd "$(dirname "$0")"

# File that stores the LG Developer session token
TOKEN_FILE="LGDevToken"

# Read token from file
if [ -s "$TOKEN_FILE" ]; then
  TOKEN=$(<"$TOKEN_FILE")
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $TOKEN_FILE not found or empty."
  exit 1
fi

URL="https://developer.lge.com/secure/ResetDevModeSession.dev?sessionToken=${TOKEN}"

RESP_BODY="$(mktemp)"
trap 'rm -f "$RESP_BODY"' EXIT

# Perform GET request
HTTP_CODE=$(curl -sS \
  --max-time 15 \
  --retry 3 --retry-delay 2 --retry-connrefused \
  -H "User-Agent: DietPi/1.0 (+https://dietpi.com)" \
  -w "%{http_code}" \
  -o "$RESP_BODY" \
  "$URL") || {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] curl execution failed."
    cat "$RESP_BODY" || true
    exit 3
}

# Print results with timestamp
echo "========== $(date '+%Y-%m-%d %H:%M:%S') =========="
echo "URL: $URL"
echo "HTTP status code: $HTTP_CODE"
echo "Response body:"
cat "$RESP_BODY"

if [[ "$HTTP_CODE" =~ ^2 ]]; then
  echo "[INFO] Success (2xx)."
else
  echo "[WARNING] Non-success status code: $HTTP_CODE"
fi

