#!/bin/bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -R "$here/../fixtures/tally/." .

# The plan has no Tip lines, so the primers alone put next-step in learning
# mode. Only failures-as-values.md matches task 1.2.
mkdir -p docs/primers
cat > docs/primers/README.md <<'MD'
# Stack primers

| Iteration(s) | File | Topics |
| --- | --- | --- |
| 1 | `failures-as-values.md` | Exceptions to values, OSError, frozen dataclasses |
| 2 | `argument-loops.md` | argparse nargs, exit status across many files |
MD
cat > docs/primers/failures-as-values.md <<'MD'
# Failures as values (Iteration 1)

## Catch OSError once

- `open()` raises a subclass of `OSError` for every read failure: `FileNotFoundError`, `IsADirectoryError`, `PermissionError`.
- Catch `OSError` once and keep `exc.strerror` as the failure's reason, instead of listing each subclass and missing one.

## Frozen dataclasses for results

- `@dataclass(frozen=True)` gives a value type with equality, so a test can compare a returned failure with `==`.
- A mutable failure invites the caller to patch it instead of reporting it.
MD
cat > docs/primers/argument-loops.md <<'MD'
# Argument loops (Iteration 2)

## Many files from argparse

- `nargs="+"` collects one or more paths into a list in argument order.
- Track the exit status across the loop; don't return on the first failure.
MD
