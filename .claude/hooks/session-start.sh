#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Ensure python3 is available (required by validate-plugin.sh)
if ! command -v python3 &>/dev/null; then
  apt-get update -qq && apt-get install -y -qq python3 >/dev/null 2>&1
fi

# Validate python3 is working
python3 -c "import json, sys" 2>/dev/null || {
  echo "ERROR: python3 json module not available" >&2
  exit 1
}
