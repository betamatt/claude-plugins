#!/usr/bin/env python3
import sys, json

try:
    inp = json.load(sys.stdin)
    tool = inp.get("tool_name", "")
    cmd = inp.get("tool_input", {}).get("command", "")

    if tool == "Bash" and "git commit" in cmd and ("Co-Authored-By" in cmd or "Generated with" in cmd):
        json.dump({
            "decision": "block",
            "reason": "The no-ai-attribution plugin prohibits Co-Authored-By lines and attribution messages in commits. Remove them from the commit message and retry."
        }, sys.stdout)
    else:
        json.dump({"decision": "approve"}, sys.stdout)
except Exception:
    json.dump({"decision": "approve"}, sys.stdout)
