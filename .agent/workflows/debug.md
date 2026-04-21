---
description: 
---

# Workflow: Debug an Error

Use this when encountering any error or unexpected behavior.

## Steps

1. Ask the user to paste the full error message and stack trace
if not already visible in context.
2. Explain the error in plain Chinese:
    - What went wrong (one sentence)
    - Why it happened (root cause)
    - Which file and line is responsible
3. Output a numbered fix plan and wait for user confirmation.
4. Apply the fix. Do not modify any file unrelated to the error.
5. Explain what the fix does and why it resolves the root cause.
6. If the same error pattern could exist elsewhere in the codebase,
search for it and report findings before closing.