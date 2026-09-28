#!/usr/bin/env bash
# SessionStart hook: print the first Todo task from docs/DEVELOPMENT_PLAN.md
# so a new, resumed or compacted session knows where the plan stands.
# Silent when there is no plan or no Todo task. Never fails the session.
set -u

# Same lookup as the skills: docs/ in the current directory, then in the
# repository root.
plan="$PWD/docs/DEVELOPMENT_PLAN.md"
if [ ! -f "$plan" ]; then
  root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
  plan="$root/docs/DEVELOPMENT_PLAN.md"
  [ -f "$plan" ] || exit 0
fi

awk '
  function flush() {
    if (id != "" && status == "Todo") {
      print "stepwise: next task in docs/DEVELOPMENT_PLAN.md is " id " " title "."
      if (goal != "") print "Goal: " goal
      found = 1
      exit
    }
  }
  { sub(/\r$/, "") }
  /^(```|~~~)/ { fenced = !fenced; next }
  fenced { next }
  /^#{1,3} / {
    flush()
    id = ""; title = ""; status = ""; goal = ""
    if (match($0, /^### [0-9]+\.[0-9]+ /)) {
      rest = substr($0, 5)
      id = rest; sub(/ .*/, "", id)
      title = rest; sub(/^[^ ]+ +/, "", title)
    }
    next
  }
  id != "" && /^- \*\*Status:\*\*/ {
    status = $0; sub(/^- \*\*Status:\*\* */, "", status); sub(/ +$/, "", status)
  }
  id != "" && /^- \*\*Goal:\*\*/ {
    goal = $0; sub(/^- \*\*Goal:\*\* */, "", goal); sub(/ +$/, "", goal)
  }
  END { if (!found) flush() }
' "$plan" 2>/dev/null

exit 0
