# The DEVELOPMENT_PLAN.md contract

`next-step` and `review-step` parse this file on every invocation. They locate a
task by heading, read its status, turn its `**Test:**` line into a checklist, and
follow its iteration's `**Requirements:**` line back into the specification. A
plan that drifts from this structure doesn't degrade gracefully — it silently
stops working.

## Required structure

```markdown
# <Project> — Iterative Implementation Plan

## Approach and assumptions

<One or two short paragraphs: what this plan assumes about the reader and the
stack. Working rules live in CLAUDE.md, not here.>

**Visible milestones:**

| After iteration | What you can demonstrate |
| --------------- | ------------------------ |
| 1               | <something runnable>     |

## Iteration <n> — <short outcome-shaped title>

**Milestone:** <what you can demonstrate once this iteration is complete>

**Requirements:** <requirement IDs from SPECIFICATION.md, e.g. ACCT-01–03, ACCT-05>

### <n>.<m> <task title, imperative>

- **Status:** Todo
- **Goal:** <the outcome, one sentence>
- **Test:** <the observable conditions that prove it>
- **Tip:** <concepts to look up — only when the developer is learning the stack>

<Optional note: a constraint that applies across this iteration's tasks.>

## Definition of completion

- <One bullet per condition that makes the whole plan done.>
```

### What the skills depend on, exactly

| Element | Depended on for |
| --- | --- |
| `## Iteration <n> — <title>` | Grouping tasks; `next-step` accepts a bare iteration number as its argument |
| `### <n>.<m> <title>` | Task identity; both skills accept a dotted id like `2.3` |
| `- **Status:** Todo\|Done\|Dropped` | Finding the next unfinished task; both skills skip `Dropped` tasks and refuse to silently re-brief a `Done` or `Dropped` one |
| `- **Goal:**` | The briefing's framing; `review-step` checks it separately from the tests |
| `- **Test:**` | Split into the definition-of-done checklist and the completion check |
| `**Requirements:**` on the iteration | Locating the governing spec sections for every task inside it |
| `**Milestone:**` on the iteration | Checking whether the iteration's last task leaves something demonstrable |
| Notes after an iteration's tasks | Cross-task constraints both skills apply to every task in that iteration |

### Requirement IDs

An ID is an uppercase prefix, a hyphen and a two-digit number: `ACCT-03`. The
`**Requirements:**` line lists IDs separated by commas. `PREFIX-NN–NN`, with an
en dash, is a range within one prefix and means every ID in it: `ACCT-01–03` is
`ACCT-01, ACCT-02, ACCT-03`. The skills expand ranges before searching, since a
range never appears literally in the specification.

In `SPECIFICATION.md`, each ID appears exactly once where it is defined: as the
first cell of a table row or at the start of a bullet. That definition is what
the skills grep for.

Keep tasks numbered `<iteration>.<position>` so ids stay unambiguous. Don't
invent another status value — the plan has `Todo`, `Done` and `Dropped`. A task
stays `Todo` until a review approves the change. `Dropped` marks a task
abandoned on purpose; it stays in the plan so its id is never reused.

## The Test line is the whole contract

This is where a plan is won or lost. `next-step` turns the line into one checkbox
per condition; `review-step` hunts the diff for evidence of each. Both work only
if the conditions are **observable and individually checkable**.

**Weak — nothing to check:**

> **Test:** Verify that importing works correctly.

`next-step` produces one useless checkbox. `review-step` can only shrug: the code
exists, so presumably it works. The task can be marked done with a broken
implementation and nobody notices.

**Strong — five checkable conditions:**

> **Test:** Import a fixture file with a header row, a blank line, a duplicate
> row and a malformed row. Verify valid rows are stored once, blank lines are
> skipped, the malformed row is reported with its line number, and a failed
> import leaves existing records untouched.

Every clause names a condition a test can assert and a reviewer can look for.
Note what it does *not* do: it never names a function, a file, or an assertion
library. It describes behavior, so the implementation stays an open choice while
the criteria stay fixed.

When writing a Test line, work through the states deliberately — the happy path,
the empty result, the failure, the retry, the boundary value, the concurrent or
out-of-order case. Most weak Test lines are weak because they only cover the
first one.

The same discipline applies to non-feature tasks:

> **Test:** Check examples of permitted and forbidden imports, including aliases
> and re-exports. Verify cycles and incorrect dependency initialization are
> rejected. Run the checks in CI.

## Sizing tasks and iterations

A task is right-sized when it is one sitting's work and its Test line has roughly
three to seven conditions. Fewer usually means it belongs merged into a
neighbour; many more means it is hiding two tasks — split it, because a
half-satisfied Test line gives `review-step` no clean verdict to report.

An iteration is right-sized when its milestone is something you could actually
show someone. Three to five tasks is typical. The number of iterations follows
the project: a small tool may need three, a full application closer to nine.

**Order iterations by demonstrable outcome, not by layer.** The tempting
sequence — all the data code, then all the logic, then all the interface — feels
organized and is a trap: nothing runs until the end, which is precisely when you
discover the layers don't fit. Prefer a thin slice that runs end to end on fake
data first, then widen it.

A workable progression for most projects:

1. Something that runs, with fixed sample data and no external dependencies.
2. The core interaction working predictably against controlled data, including
   its slow and failing paths.
3. Real external services replacing the samples.
4. The remaining journeys.
5. Persistence, if any.
6. Behavior under failure, interruption and concurrency.
7. Cross-cutting concerns — languages, accessibility, appearance.
8. Verification and release.

Adapt it; don't follow it mechanically. A library with no interface and no
storage skips most of it.

## Goal versus Test

The `**Goal:**` line is the outcome in one sentence. The `**Test:**` line is the
evidence. They are checked separately because a task can satisfy every literal
test condition and still miss its goal — the tests pass, but the feature isn't
reachable by a user yet. Keeping them distinct is what lets `review-step` surface
that gap instead of reporting a green checklist.

Write the Goal so it names the outcome, not the activity: "Bring existing
records in from a spreadsheet without losing or duplicating any" rather than
"Implement CSV import."

## Tip lines

Include them only when the developer is learning the stack. When present, a Tip
names concepts to look up, never instructions to follow:

> **Tip:** Look up streaming parsers, idempotent writes, and transactions.

Linking to primary documentation is fine. Explaining the concept inline is not —
that turns the plan into a tutorial and defeats the point of leaving the
implementation as an exercise. When the developer knows the stack, omit the line
entirely rather than writing a thin one.

## Notes between tasks

A short standalone line after an iteration's tasks is the right place for a
constraint that applies across them:

> Keep live-service smoke tests separate from automated tests that must run
> offline.

Use these sparingly, for genuine cross-task constraints. Anything longer belongs
in a governing document, with the plan referencing it.
