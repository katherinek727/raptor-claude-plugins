#!/bin/bash
# Only inject reminder if response doesn't already contain evidence labels
INPUT=$(cat)
if echo "$INPUT" | grep -qE '\[(FACT|ASSUMED|INFERRED)\]'; then
    exit 0
fi

cat << 'EOF'
<protocol-reminder>
Response Style Checklist:
- Did you cite [FACT] or [INFERRED] evidence for your approach?
- If uncertain: Label it [ASSUMED] and ASK before proceeding
</protocol-reminder>
EOF
