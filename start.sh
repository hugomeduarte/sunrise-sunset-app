#!/usr/bin/env bash
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
BACKEND_PID=""

cleanup() {
  if [[ -n "$BACKEND_PID" ]] && kill -0 "$BACKEND_PID" 2>/dev/null; then
    echo ""
    echo "Stopping backend (PID $BACKEND_PID)..."
    kill "$BACKEND_PID" 2>/dev/null || true
  fi
  exit 0
}
trap cleanup SIGINT SIGTERM

echo "== Backend: install =="
(cd "$ROOT/backend" && bundle install)

echo "== Backend: database (create + migrate) =="
(cd "$ROOT/backend" && bin/rails db:create db:migrate)

echo "== Backend: starting server (port 3000) =="
(cd "$ROOT/backend" && bin/rails server) &
BACKEND_PID=$!

sleep 2
echo "== Frontend: install =="
(cd "$ROOT/frontend" && pnpm install)

echo "== Frontend: starting dev server (port 5173) =="
(cd "$ROOT/frontend" && pnpm dev)
