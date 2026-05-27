#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PID_FILE=".dev-server.pid"

if [ ! -f "$PID_FILE" ]; then
  exit 0
fi

PID="$(cat "$PID_FILE")"
rm -f "$PID_FILE"

if kill -0 "$PID" >/dev/null 2>&1; then
  echo "Stopping JoicreMemory backend PID ${PID}..."
  kill "$PID" >/dev/null 2>&1 || true
fi

