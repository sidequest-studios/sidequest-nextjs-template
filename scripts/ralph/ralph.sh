#!/bin/bash
set -e

MAX_ITERATIONS=${1:-10}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Starting Ralph - autonomous coding loop"
echo "Project root: $PROJECT_ROOT"
echo "Max iterations: $MAX_ITERATIONS"
echo ""

cd "$PROJECT_ROOT"

# jq filter to extract streaming text from assistant messages
stream_text='select(.type == "assistant").message.content[]? | select(.type == "text").text // empty | gsub("\n"; "\r\n") | . + "\r\n\n"'

# jq filter to extract final result
final_result='select(.type == "result").result // empty'

for i in $(seq 1 $MAX_ITERATIONS); do
  echo "═══════════════════════════════════════════════════════════"
  echo "═══ Iteration $i of $MAX_ITERATIONS ═══"
  echo "═══════════════════════════════════════════════════════════"

  tmpfile=$(mktemp)
  trap "rm -f $tmpfile" EXIT

  # Stream output in real-time while capturing for completion check
  cat "$SCRIPT_DIR/prompt.md" | claude \
    --dangerously-skip-permissions \
    --verbose \
    --output-format stream-json \
  | grep --line-buffered '^{' \
  | tee "$tmpfile" \
  | jq --unbuffered -rj "$stream_text" || true

  result=$(jq -r "$final_result" "$tmpfile" 2>/dev/null || echo "")

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    rm -f "$tmpfile"
    echo ""
    echo "All tasks complete! Ralph is done."
    exit 0
  fi

  rm -f "$tmpfile"
  echo ""
  echo "Sleeping 2s before next iteration..."
  sleep 2
done

echo ""
echo "Max iterations ($MAX_ITERATIONS) reached without completion"
echo "Check progress.txt and prd.json to see what's left"
exit 1
