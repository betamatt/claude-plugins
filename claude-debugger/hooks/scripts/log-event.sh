#!/bin/bash
# Debug logger for Claude Code plugin events
# Usage: log-event.sh <type> <name> [detail]

set -e

TYPE="$1"
NAME="$2"
DETAIL="${3:-}"

# Configuration
LOG_FILE=".claude/debug.log"
SETTINGS_FILE=".claude/debugger.yaml"

# Default verbosity
VERBOSITY="normal"

# Read verbosity from settings file if it exists
if [[ -f "$SETTINGS_FILE" ]]; then
  VERBOSITY_LINE=$(grep -E "^verbosity:" "$SETTINGS_FILE" 2>/dev/null || true)
  if [[ -n "$VERBOSITY_LINE" ]]; then
    VERBOSITY=$(echo "$VERBOSITY_LINE" | sed 's/verbosity:[[:space:]]*//' | tr -d '[:space:]')
  fi
fi

# Check if logging is disabled
if [[ "$VERBOSITY" == "off" ]]; then
  exit 0
fi

# Determine if this event should be logged based on verbosity
should_log() {
  local type="$1"
  local level="$2"

  case "$level" in
    minimal)
      # Only skills and subagents
      [[ "$type" == "SKILL" || "$type" == "AGENT" ]]
      ;;
    normal)
      # Skills, subagents, commands, hooks
      [[ "$type" == "SKILL" || "$type" == "AGENT" || "$type" == "CMD" || "$type" == "HOOK" ]]
      ;;
    verbose)
      # Everything
      return 0
      ;;
    *)
      # Default to normal
      [[ "$type" == "SKILL" || "$type" == "AGENT" || "$type" == "CMD" || "$type" == "HOOK" ]]
      ;;
  esac
}

# Check if we should log this event
if ! should_log "$TYPE" "$VERBOSITY"; then
  exit 0
fi

# Ensure .claude directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Get timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Build JSON log entry
if [[ -n "$DETAIL" ]]; then
  JSON="{\"time\":\"$TIMESTAMP\",\"type\":\"$TYPE\",\"name\":\"$NAME\",\"detail\":\"$DETAIL\"}"
else
  JSON="{\"time\":\"$TIMESTAMP\",\"type\":\"$TYPE\",\"name\":\"$NAME\"}"
fi

# Append to log file
echo "$JSON" >> "$LOG_FILE"
