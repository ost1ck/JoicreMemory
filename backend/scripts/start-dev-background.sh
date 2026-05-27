#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PORT="${PORT:-3000}"
HEALTH_URL="http://localhost:${PORT}/api/health"
PID_FILE=".dev-server.pid"
LOG_FILE=".dev-server.log"

if curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
  echo "Backend already running on ${HEALTH_URL}"
  exit 0
fi

if [ -f "$PID_FILE" ]; then
  PID="$(cat "$PID_FILE")"
  if kill -0 "$PID" >/dev/null 2>&1; then
    echo "Backend is already starting with PID ${PID}"
  else
    rm -f "$PID_FILE"
  fi
fi

if [ ! -f "$PID_FILE" ]; then
  echo "Starting JoicreMemory backend on port ${PORT}..."
  nohup npm run dev > "$LOG_FILE" 2>&1 &
  echo "$!" > "$PID_FILE"
  disown >/dev/null 2>&1 || true
fi

for _ in $(seq 1 30); do
  if curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
    echo "Backend is ready: ${HEALTH_URL}"
    exit 0
  fi

  sleep 1
done

echo "Backend did not become ready in time."
echo "Last backend log lines:"
tail -n 80 "$LOG_FILE" || true
exit 1
