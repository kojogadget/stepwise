#!/bin/bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -R "$here/../fixtures/tally/." .

# A run that stopped after phase 2: the spec and architecture are approved,
# the technical design, conventions and plan are still to be written.
rm docs/TECHNICAL_DESIGN.md docs/CODING_CONVENTIONS.md docs/DEVELOPMENT_PLAN.md
