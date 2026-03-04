#!/usr/bin/env bash
set -euo pipefail

# validate-plugin.sh — Structural validation for ClinearHub plugin
# Run from repo root or plugin root. CI integration: release-plugin.yml

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ERRORS=0
WARNINGS=0

red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
info()   { printf '  %s\n' "$*"; }

error() { ERRORS=$((ERRORS + 1)); red "ERROR: $*"; }
warn()  { WARNINGS=$((WARNINGS + 1)); yellow "WARN:  $*"; }
pass()  { green "PASS:  $*"; }

echo "=== ClinearHub Plugin Validator ==="
echo "Plugin dir: $PLUGIN_DIR"
echo ""

# --- 1. plugin.json schema ---
echo "--- plugin.json ---"
PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"

if [ ! -f "$PLUGIN_JSON" ]; then
  error "plugin.json not found at $PLUGIN_JSON"
else
  # Required fields
  for field in name version description; do
    val=$(python3 -c "import json,sys; d=json.load(open('$PLUGIN_JSON')); print(d.get('$field',''))" 2>/dev/null || echo "")
    if [ -z "$val" ]; then
      error "plugin.json missing required field: $field"
    fi
  done

  # Version format (semver-ish)
  ver=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON')).get('version',''))" 2>/dev/null || echo "")
  if [[ ! "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error "plugin.json version '$ver' is not valid semver (expected X.Y.Z)"
  else
    pass "plugin.json valid (v$ver)"
  fi
fi

# --- 2. Skills have valid SKILL.md with required frontmatter ---
echo ""
echo "--- Skills ---"
SKILL_COUNT=0
SKILL_DIRS=$(find "$PLUGIN_DIR/skills" -mindepth 1 -maxdepth 1 -type d -not -name '_archived' 2>/dev/null | sort)

if [ -z "$SKILL_DIRS" ]; then
  error "No skill directories found in $PLUGIN_DIR/skills/"
else
  while IFS= read -r skill_dir; do
    skill_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"

    if [ ! -f "$skill_file" ]; then
      error "Skill '$skill_name' has no SKILL.md"
      continue
    fi

    SKILL_COUNT=$((SKILL_COUNT + 1))

    # Extract YAML frontmatter (between first two --- lines)
    frontmatter=$(awk '/^---$/{n++; next} n==1{print} n>=2{exit}' "$skill_file")

    # Check required frontmatter fields
    fm_name=$(echo "$frontmatter" | grep -E '^name:' | head -1 | sed 's/^name:[[:space:]]*//')
    fm_desc=$(echo "$frontmatter" | grep -E '^description:' | head -1 | sed 's/^description:[[:space:]]*//')

    if [ -z "$fm_name" ]; then
      error "Skill '$skill_name/SKILL.md' missing frontmatter field: name"
    elif [ "$fm_name" != "$skill_name" ]; then
      warn "Skill '$skill_name' frontmatter name '$fm_name' doesn't match directory name"
    fi

    if [ -z "$fm_desc" ]; then
      error "Skill '$skill_name/SKILL.md' missing frontmatter field: description"
    fi

    # Check body has content after frontmatter
    body_lines=$(awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "$skill_file" | grep -c '[^[:space:]]' || true)
    if [ "$body_lines" -eq 0 ]; then
      warn "Skill '$skill_name/SKILL.md' has empty body after frontmatter"
    fi

  done <<< "$SKILL_DIRS"

  pass "$SKILL_COUNT skills validated"
fi

# --- 3. No orphaned commands ---
echo ""
echo "--- Legacy Commands ---"
COMMANDS_DIR="$PLUGIN_DIR/commands"
if [ -d "$COMMANDS_DIR" ]; then
  cmd_count=$(find "$COMMANDS_DIR" -name '*.md' | wc -l | tr -d ' ')
  if [ "$cmd_count" -gt 0 ]; then
    warn "$cmd_count legacy command files in commands/ — migrate to skills/"
    find "$COMMANDS_DIR" -name '*.md' -exec basename {} \; | while read -r f; do
      info "  orphaned: $f"
    done
  else
    pass "commands/ exists but is empty"
  fi
else
  pass "No legacy commands/ directory"
fi

# --- 4. .mcp.json format ---
echo ""
echo "--- .mcp.json ---"
MCP_JSON="$PLUGIN_DIR/.mcp.json"

if [ ! -f "$MCP_JSON" ]; then
  warn ".mcp.json not found (no MCP connectors bundled)"
else
  # Valid JSON
  if ! python3 -c "import json; json.load(open('$MCP_JSON'))" 2>/dev/null; then
    error ".mcp.json is not valid JSON"
  else
    # Must have mcpServers key
    has_servers=$(python3 -c "import json; d=json.load(open('$MCP_JSON')); print('yes' if 'mcpServers' in d else 'no')" 2>/dev/null)
    if [ "$has_servers" != "yes" ]; then
      error ".mcp.json missing 'mcpServers' key"
    else
      # Each server must have type and url
      server_errors=$(python3 -c "
import json, sys
d = json.load(open('$MCP_JSON'))
errors = []
for name, cfg in d.get('mcpServers', {}).items():
    if 'type' not in cfg:
        errors.append(f'{name}: missing type')
    if 'url' not in cfg and 'command' not in cfg:
        errors.append(f'{name}: missing url or command')
for e in errors:
    print(e)
" 2>/dev/null)
      if [ -n "$server_errors" ]; then
        while IFS= read -r err; do
          error ".mcp.json server $err"
        done <<< "$server_errors"
      else
        srv_count=$(python3 -c "import json; print(len(json.load(open('$MCP_JSON')).get('mcpServers',{})))" 2>/dev/null)
        pass ".mcp.json valid ($srv_count servers)"
      fi
    fi
  fi
fi

# --- 5. CLAUDE_PLUGIN_ROOT references resolve ---
echo ""
echo "--- Path References ---"
ref_errors=0
while IFS= read -r skill_file; do
  # Find ${CLAUDE_PLUGIN_ROOT} references and extract the path
  refs=$(grep -oE '\$\{CLAUDE_PLUGIN_ROOT\}[^ )"'"'"']*' "$skill_file" 2>/dev/null || true)
  if [ -n "$refs" ]; then
    while IFS= read -r ref; do
      # Replace ${CLAUDE_PLUGIN_ROOT} with plugin dir to check existence
      resolved="${ref/\$\{CLAUDE_PLUGIN_ROOT\}/$PLUGIN_DIR}"
      if [ ! -e "$resolved" ]; then
        error "Broken reference in $(basename "$(dirname "$skill_file")")/SKILL.md: $ref"
        ref_errors=$((ref_errors + 1))
      fi
    done <<< "$refs"
  fi
done < <(find "$PLUGIN_DIR/skills" -name 'SKILL.md' 2>/dev/null)

if [ "$ref_errors" -eq 0 ]; then
  pass "All \${CLAUDE_PLUGIN_ROOT} references resolve"
fi

# --- Summary ---
echo ""
echo "=== Summary ==="
echo "Skills: $SKILL_COUNT"
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"

if [ "$ERRORS" -gt 0 ]; then
  red "FAILED — fix $ERRORS error(s) before release"
  exit 1
else
  if [ "$WARNINGS" -gt 0 ]; then
    yellow "PASSED with $WARNINGS warning(s)"
  else
    green "PASSED"
  fi
  exit 0
fi
