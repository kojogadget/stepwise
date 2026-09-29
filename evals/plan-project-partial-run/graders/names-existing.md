---
type: llm
---

docs/ holds SPECIFICATION.md and ARCHITECTURE.md; TECHNICAL_DESIGN.md,
CODING_CONVENTIONS.md and DEVELOPMENT_PLAN.md are missing.
PASS if the response tells the user that SPECIFICATION.md and ARCHITECTURE.md
already exist. It need not list every missing document by name.
FAIL if it doesn't name both existing documents, or claims one of the missing
documents already exists.
