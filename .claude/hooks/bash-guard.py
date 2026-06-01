#!/usr/bin/env python3
"""PreToolUse Bash guard for RenaissanceArchitectAcademy.

Hard-blocks two mistakes that CLAUDE.md only described in prose:
  1. Killing actool/ibtoold — wedges the asset catalog and needs a Mac reboot.
  2. Inlining a secret into a Bash command — leaks into settings.local.json forever.

Reads the tool-call JSON on stdin; exit 2 blocks the call and shows the message
to Claude. Any parse error → exit 0 (fail open: never break normal commands).
"""
import sys
import re
import json

try:
    data = json.load(sys.stdin)
    cmd = data.get("tool_input", {}).get("command", "") or ""
except Exception:
    sys.exit(0)

# 1. actool / ibtoold kill guard (the Mac-reboot mistake — CLAUDE.md Durable Constraints)
if re.search(r"\b(pkill|killall)\b.*(actool|ibtoold)", cmd) or \
   re.search(r"\bkill\b.*(actool|ibtoold)", cmd):
    sys.stderr.write(
        "BLOCKED: killing actool/ibtoold wedges the asset catalog and needs a "
        "Mac reboot (CLAUDE.md Durable Constraints). Quit/relaunch "
        "Xcode instead; never pkill these.\n"
    )
    sys.exit(2)

# 2. inlined-secret guard (CLAUDE.md MANDATORY Rules). Require a real secret-shaped value
# (a long token), so merely *mentioning* the patterns (docs, commit messages,
# grep) doesn't trip it — only an actual inlined key/token does.
_SECRET = (
    r"sk-ant-[A-Za-z0-9_-]{16,}"
    r"|(?:PROXY_TOKEN|ANTHROPIC_API_KEY)\s*=\s*['\"]?[A-Za-z0-9_-]{16,}"
    r"|Authorization:\s*Bearer\s+[A-Za-z0-9._-]{16,}"
)
if re.search(_SECRET, cmd):
    sys.stderr.write(
        "BLOCKED: this command looks like it inlines a secret. Per CLAUDE.md MANDATORY Rules, "
        "`export VAR=...` in your own shell (or `export VAR=$(cat gitignored-file)`) "
        "and run the bare command — never put the secret in the command string.\n"
    )
    sys.exit(2)

sys.exit(0)
