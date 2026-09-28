#!/bin/bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -R "$here/../fixtures/tally/." .

# Drop task 1.2, so the first task that isn't Done is Dropped rather than Todo.
sed -i.bak '/^### 1\.2 /,/^- \*\*Status:\*\*/ s/\*\*Status:\*\* Todo/**Status:** Dropped/' docs/DEVELOPMENT_PLAN.md
rm docs/DEVELOPMENT_PLAN.md.bak
grep -q '^- \*\*Status:\*\* Dropped$' docs/DEVELOPMENT_PLAN.md
