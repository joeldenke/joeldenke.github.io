#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

PORT=8080

# Kill any existing server on the port
pkill -f "python3 -m http.server $PORT" 2>/dev/null || true

# Start HTTP preview server in background
cd "${CLAUDE_PROJECT_DIR:-.}"
nohup python3 -m http.server "$PORT" --bind 0.0.0.0 > /tmp/preview-server.log 2>&1 &

echo "Preview server started on port $PORT" >&2
