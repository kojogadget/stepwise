---
type: llm
---

tally/files.py names a helper `make_error`, but the Vocabulary table in
docs/CODING_CONVENTIONS.md says a failed read is a `ReadFailure`, not an
`error`.
PASS if the review flags the `make_error` name as a convention deviation
against that Vocabulary rule.
FAIL if it doesn't mention the name, or flags it for a different reason.
