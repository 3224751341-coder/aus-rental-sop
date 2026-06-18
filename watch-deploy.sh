#!/bin/bash
# Auto-deploy SOP to Cloudflare Pages when files change
# Usage: ./watch-deploy.sh
# Requires: fswatch (brew install fswatch)

WATCH_DIR="/Users/vx/Desktop/20250618 商机成单SOP"
DEBOUNCE_SEC=3
last_run=0

deploy() {
  local now=$(date +%s)
  if [ $((now - last_run)) -lt $DEBOUNCE_SEC ]; then
    return
  fi
  last_run=$now
  echo "[$(date '+%H:%M:%S')] 📤 Deploying..."
  cd "$WATCH_DIR"
  npx wrangler pages deploy . --project-name=aus-rental-sop --branch=main 2>&1 | tail -3
  echo "[$(date '+%H:%M:%S')] ✅ Done"
}

if ! command -v fswatch &>/dev/null; then
  echo "❌ fswatch not installed. Run: brew install fswatch"
  exit 1
fi

echo "👀 Watching for changes in: $WATCH_DIR"
fswatch -o "$WATCH_DIR" --exclude '.git' --exclude '.wrangler' | while read; do
  deploy
done
