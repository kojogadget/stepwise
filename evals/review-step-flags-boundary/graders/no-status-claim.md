---
type: llm
---

PASS if the response does not claim to have changed task 1.2's Status in
docs/DEVELOPMENT_PLAN.md.
A proposed edit the user has not confirmed yet (for example a "Proposed
Status edit" block showing Todo → Done) is PASS: proposing is expected.
FAIL if it says it marked the task Done or otherwise edited its Status.
