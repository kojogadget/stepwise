---
type: llm
---

PASS if the response is a briefing for task 1.2 "Report read failures as
values" (not the Done task 1.1 or the later 2.1), that:
- ties it to requirement IDs from CNT-01–04,
- names the architecture rule that the files module never prints or exits,
  or the invariant that read failures are returned as values,
- uses the vocabulary term `ReadFailure`,
- turns the Test line into separate checklist items (readable file, missing
  file, directory, nothing printed),
- talks about Python idioms rather than any other stack,
- and ends by handing control back instead of implementing the feature.
FAIL otherwise.
