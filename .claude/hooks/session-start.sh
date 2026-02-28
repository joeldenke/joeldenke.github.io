#!/bin/bash
set -euo pipefail

# Only run in remote Claude Code on the web sessions
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

PORT=3000
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Kill any existing server on the port
if lsof -ti :"$PORT" >/dev/null 2>&1; then
  echo "Stopping existing server on port $PORT..."
  lsof -ti :"$PORT" | xargs kill -9 2>/dev/null || true
  sleep 1
fi

# Start browser-sync with live-reload in background
echo "Starting live-reload preview server on port $PORT..."
cd "$PROJECT_DIR"
nohup npx --yes browser-sync start \
  --server \
  --files "*.html,*.css,*.js" \
  --port "$PORT" \
  --no-open \
  --no-notify \
  > /tmp/preview-server.log 2>&1 &
echo $! > /tmp/preview-server.pid

# Wait for server to start
sleep 3
if kill -0 "$(cat /tmp/preview-server.pid)" 2>/dev/null; then
  echo "Live-reload preview server running at http://localhost:$PORT (PID: $(cat /tmp/preview-server.pid))"
  echo "Page reloads automatically when HTML/CSS/JS files change."
else
  echo "ERROR: Preview server failed to start. Check /tmp/preview-server.log"
  cat /tmp/preview-server.log || true
  exit 1
fi
