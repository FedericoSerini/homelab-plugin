#!/usr/bin/env bash
# Injects INFRA.md from the current project into session context.
# Looks in .claude/INFRA.md relative to CWD (where Claude Code was opened).

INFRA_FILE=".claude/INFRA.md"

if [ -f "$INFRA_FILE" ]; then
  echo "HOMELAB CONTEXT LOADED:"
  echo ""
  cat "$INFRA_FILE"
else
  echo "HOMELAB PLUGIN ACTIVE — no INFRA.md found at .claude/INFRA.md"
  echo "Run /hl-init to generate a template, or create .claude/INFRA.md manually."
fi
