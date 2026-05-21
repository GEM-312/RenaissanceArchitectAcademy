#!/bin/zsh
#
# RAA auto-builder — watches the app source dir for .swift saves and
# kicks off a background `xcodebuild` so DerivedData is warm by the
# time you press Cmd+R in Xcode.
#
# Setup (one-time):
#   brew install fswatch
#
# Run (foreground, for testing):
#   ./scripts/raa-autobuild.sh
#
# Run (background, autostart on login):
#   See scripts/raa-autobuild.plist + load instructions at the bottom.
#
# Stops automatically if Xcode is currently building or if a prior
# auto-build is still running, so we never conflict with the foreground
# Xcode build that Marina actually cares about.
#
# Caveat: pressing Cmd+Shift+K (Clean Build Folder) wipes DerivedData
# and undoes the cache warming. Most useful when you DON'T clean.

set -uo pipefail

PROJECT_ROOT="/Users/pollakmarina/RenaissanceArchitectAcademy"
WATCH_DIR="$PROJECT_ROOT/RenaissanceArchitectAcademy"
LOG="/tmp/raa-autobuild.log"
LOCK="/tmp/raa-autobuild.lock"
DEBOUNCE_SECONDS=3

if ! command -v fswatch >/dev/null 2>&1; then
  echo "fswatch not installed. Run: brew install fswatch" >&2
  exit 1
fi

log() {
  echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG"
}

log "auto-builder starting — watching $WATCH_DIR"

# fswatch options:
#   -l <sec>     debounce window (collapse rapid saves into one event)
#   -o           output event count instead of paths (one line per batch)
#   --event Updated  only fire on writes (ignore renames, attribute changes)
fswatch -l "$DEBOUNCE_SECONDS" -o --event Updated "$WATCH_DIR" \
  | while read -r _; do

  if [ -f "$LOCK" ]; then
    log "skip — previous build still running"
    continue
  fi

  if pgrep -x xcodebuild >/dev/null 2>&1; then
    log "skip — Xcode is building right now"
    continue
  fi

  touch "$LOCK"
  log "build start"

  cd "$PROJECT_ROOT" || { rm "$LOCK"; continue; }
  xcodebuild \
    -scheme RenaissanceArchitectAcademy \
    -destination 'platform=macOS' \
    -quiet \
    build >/tmp/raa-autobuild-last.log 2>&1
  exit_code=$?

  if [ $exit_code -eq 0 ]; then
    log "build OK (exit 0) — DerivedData warm"
  else
    log "build FAILED (exit $exit_code) — see /tmp/raa-autobuild-last.log"
  fi

  rm -f "$LOCK"
done
