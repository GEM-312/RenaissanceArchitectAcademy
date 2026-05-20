#!/bin/zsh
#
# RAA worker dashboard — streams `wrangler tail` and shows a compact
# tally of recent requests + errors + the freshest log line. Designed
# for a small pinned terminal window you glance at while working.
#
# Tally window: last 5 minutes (sliding).
# Refresh: redrawn on every tail event (no busy-loop polling).
#
# Run:
#   ./scripts/raa-dashboard.sh
#
# Stop: Ctrl+C
#
# Requires: wrangler (already a project dep in cloudflare-worker/).

set -uo pipefail

WORKER_DIR="/Users/pollakmarina/RenaissanceArchitectAcademy/cloudflare-worker"
WINDOW_SECONDS=300   # 5 minutes
EVENT_LOG="/tmp/raa-dashboard-events.log"

if ! command -v node >/dev/null 2>&1; then
  echo "node not installed. Required for wrangler." >&2
  exit 1
fi

cd "$WORKER_DIR"

# Truncate the event log so old tallies don't bleed over from prior runs.
: > "$EVENT_LOG"

# Render the dashboard at the top of the terminal, clearing the screen.
render() {
  local now
  now=$(date +%s)
  local cutoff=$((now - WINDOW_SECONDS))

  # Count events newer than the cutoff.
  local req_count err_count last_line last_time
  req_count=$(awk -v c="$cutoff" '$1 >= c && $2 == "REQ"' "$EVENT_LOG" | wc -l | tr -d ' ')
  err_count=$(awk -v c="$cutoff" '$1 >= c && $2 == "ERR"' "$EVENT_LOG" | wc -l | tr -d ' ')
  last_line=$(tail -1 "$EVENT_LOG" 2>/dev/null | cut -d'|' -f3-)
  last_time=$(tail -1 "$EVENT_LOG" 2>/dev/null | cut -d'|' -f1)
  local since_last="—"
  if [ -n "$last_time" ]; then
    since_last="$((now - last_time))s ago"
  fi

  clear
  printf "╔══════════════════════════════════════════════════════════════╗\n"
  printf "║  RAA WORKER · raa-api.pollak.workers.dev · last 5 min        ║\n"
  printf "╠══════════════════════════════════════════════════════════════╣\n"
  printf "║  Requests:  %-6s   Errors: %-6s   Last event: %-12s ║\n" "$req_count" "$err_count" "$since_last"
  printf "╚══════════════════════════════════════════════════════════════╝\n"
  printf "\n"
  printf "Latest event:\n"
  printf "  %s\n" "${last_line:-(no events yet — make a request to the worker)}"
  printf "\n"
  printf "(streaming wrangler tail · Ctrl+C to stop)\n"
}

# Initial render before any events arrive.
render

# Pipe wrangler tail through a parser that:
#  1. classifies each line as REQ or ERR
#  2. appends "<unix_time>|<class>|<line>" to the event log
#  3. triggers a re-render
npx wrangler tail --format pretty 2>/dev/null | while IFS= read -r line; do
  ts=$(date +%s)
  class="REQ"
  case "$line" in
    *"error"*|*"Error"*|*"ERR"*|*"401"*|*"500"*|*"failed"*|*"Failed"*) class="ERR" ;;
  esac
  printf "%s|%s|%s\n" "$ts" "$class" "$line" >> "$EVENT_LOG"
  render
done
