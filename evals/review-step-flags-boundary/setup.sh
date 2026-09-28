#!/bin/bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -R "$here/../fixtures/tally/." .

# Keep the developer's git config (signing, hooks, templates) out of the
# fixture repository.
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_CONFIG_NOSYSTEM=1
mkdir -p tally tests
cat > tally/counting.py <<'PY'
def count_words(text: str) -> int:
    return len(text.split())
PY
git init -q -b main
git -c user.name=eval -c user.email=eval@example.com add .
git -c user.name=eval -c user.email=eval@example.com commit -q -m "feat: count words in a string"
git checkout -q -b read-failures
cat > tally/files.py <<'PY'
import sys
from dataclasses import dataclass


@dataclass(frozen=True)
class ReadFailure:
    path: str
    reason: str


def read_text(path: str) -> "str | ReadFailure":
    try:
        with open(path, encoding="utf-8") as handle:
            return handle.read()
    except FileNotFoundError:
        print(f"tally: {path}: no such file", file=sys.stderr)
        sys.exit(1)
    except IsADirectoryError:
        return ReadFailure(path, "directory")
PY
cat > tests/test_files.py <<'PY'
from tally.files import ReadFailure, read_text


def test_readable_file_returns_text(tmp_path):
    path = tmp_path / "a.txt"
    path.write_text("one two")
    assert read_text(str(path)) == "one two"


def test_directory_returns_read_failure(tmp_path):
    assert isinstance(read_text(str(tmp_path)), ReadFailure)
PY
