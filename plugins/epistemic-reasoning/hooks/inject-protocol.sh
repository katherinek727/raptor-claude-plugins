#!/usr/bin/env bash

# Epistemic Reasoning Protocol Injection Hook (SessionStart)
# Injects protocol once at session start, not on every prompt

SKILL_FILE="${CLAUDE_PLUGIN_ROOT}/skills/epistemic-protocol/SKILL.md"

# Check if skill file exists
if [ ! -f "$SKILL_FILE" ]; then
    echo '{"error": "SKILL.md not found"}' >&2
    exit 1
fi

# Try jq first, fall back to python3 if unavailable
if command -v jq &> /dev/null; then
    # Use jq for JSON escaping
    SKILL_CONTENT=$(cat "$SKILL_FILE")
    ESCAPED_CONTENT=$(echo "$SKILL_CONTENT" | jq -Rs .)

    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ESCAPED_CONTENT
  }
}
EOF
else
    # Fall back to python3
    python3 -c "
import json
import sys

with open('$SKILL_FILE', 'r') as f:
    content = f.read()

output = {
    'hookSpecificOutput': {
        'hookEventName': 'SessionStart',
        'additionalContext': content
    }
}

print(json.dumps(output))
"
fi

exit 0
