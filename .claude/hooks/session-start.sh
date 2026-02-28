#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

PORT=8080
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

# Kill any existing server on the port
pkill -f "python3 -m http.server $PORT" 2>/dev/null || true
sleep 1

# Start HTTP preview server in background
cd "$PROJECT_DIR"
nohup python3 -m http.server "$PORT" --bind 0.0.0.0 > /tmp/preview-server.log 2>&1 &
SERVER_PID=$!

# Wait briefly and verify it started
sleep 2
if kill -0 "$SERVER_PID" 2>/dev/null && curl -s --max-time 2 "http://localhost:$PORT/" -o /dev/null; then
  echo "PREVIEW_URL=http://localhost:$PORT" >> "${CLAUDE_ENV_FILE:-/dev/null}"
  cat >&2 << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    PREVIEW SERVER STARTED                    ║
╠══════════════════════════════════════════════════════════════╣
║  Intern URL:  http://localhost:8080  (curl i containern)     ║
║  Browser:     www.joeldenke.se  (pusha till main)            ║
║                                                              ║
║  Tips: be Claude att köra  curl localhost:8080               ║
║         för att inspektera HTML utan att pusha               ║
╚══════════════════════════════════════════════════════════════╝
EOF
else
  echo "WARNING: Preview server failed to start" >&2
fi
