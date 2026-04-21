---
description: 
---

# Workflow: Code Review

Use this before marking any task as complete.

## Steps

1. Read every file modified in the current task.
2. Check against each rule file in order:
    - [code-style.md](http://code-style.md/): naming, formatting, trailing commas, const usage
    - [architecture.md](http://architecture.md/): layer boundaries, no skipped layers, no magic strings
    - [testing.md](http://testing.md/): test file exists for any new repository or provider
3. Report findings grouped by severity:
    
    MUST FIX — violates a project rule, must be corrected now
    SUGGESTION — improvement but not a rule violation
    
4. If there are MUST FIX items: fix them all, then re-run the review.
If only SUGGESTIONS remain: list them and ask user whether to apply.
5. Output final status: PASSED or FIXED (with list of what was changed).