#!/bin/bash
# Single iteration for human-in-the-loop (HITL) mode
# Use this to watch Ralph work and intervene when needed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Running single Ralph iteration (HITL mode)"
echo "Project root: $PROJECT_ROOT"
echo ""

cd "$PROJECT_ROOT"

cat "$SCRIPT_DIR/prompt.md" | claude --dangerously-skip-permissions

echo ""
echo "Single iteration complete. Review changes before running again."
