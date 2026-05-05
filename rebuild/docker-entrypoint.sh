#!/usr/bin/env bash
# docker-entrypoint.sh — Claw_Rising Rebuild entrypoint
# Handles staging vs prod mode and service orchestration.
set -e

MODE="${1:-staging}"

log() {
  echo "[entrypoint] $(date '+%Y-%m-%d %H:%M:%S') $*"
}

# ── Wait for the .env file to be populated (from bind-mount or secrets) ──
wait_for_env() {
  if [ -f /home/samuel/.env ]; then
    set -a
    # shellcheck disable=SC1091
    . /home/samuel/.env
    set +a
    log ".env loaded"
  else
    log "WARNING: no /home/samuel/.env found — using defaults or empty vars"
  fi
}

# ── Start OpenClaw gateway ───────────────────────────────────────────────
start_gateway() {
  log "Starting OpenClaw gateway on port 19000..."
  nohup openclaw gateway --port 19000 > /tmp/gateway.log 2>&1 &
  GATEWAY_PID=$!
  log "Gateway PID: $GATEWAY_PID"
}

# ── Start Gallery backend (FastAPI) ──────────────────────────────────────
start_gallery_backend() {
  log "Starting Gallery backend on port 8001..."
  nohup uvicorn gallery.main:app --host 0.0.0.0 --port 8001 \
    ${MODE:+"--reload"} > /tmp/gallery-backend.log 2>&1 &
  BACKEND_PID=$!
  log "Backend PID: $BACKEND_PID"
}

# ── Start Gallery frontend (Next.js) ─────────────────────────────────────
start_gallery_frontend() {
  if [ -d /home/samuel/projects/gallery/frontend/node_modules ]; then
    log "Starting Gallery frontend on port 3000..."
    cd /home/samuel/projects/gallery/frontend
    if [ "$MODE" = "staging" ]; then
      nohup npm run dev > /tmp/gallery-frontend.log 2>&1 &
    else
      nohup npm start > /tmp/gallery-frontend.log 2>&1 &
    fi
    FRONTEND_PID=$!
    log "Frontend PID: $FRONTEND_PID"
    cd /home/samuel
  else
    log "Frontend node_modules not found — skipping"
  fi
}

# ── shell-style cleanup ──────────────────────────────────────────────────
cleanup() {
  log "Shutting down..."
  kill "$GATEWAY_PID" 2>/dev/null || true
  kill "$BACKEND_PID" 2>/dev/null || true
  kill "$FRONTEND_PID" 2>/dev/null || true
  exit 0
}
trap cleanup SIGINT SIGTERM

# ── Main ─────────────────────────────────────────────────────────────────
log "Starting in $MODE mode"

wait_for_env
start_gateway
start_gallery_backend
start_gallery_frontend

log "All services started. Container will run until stopped."

# Tail logs to keep container alive
touch /tmp/gateway.log /tmp/gallery-backend.log /tmp/gallery-frontend.log
tail -f /tmp/gateway.log /tmp/gallery-backend.log /tmp/gallery-frontend.log
