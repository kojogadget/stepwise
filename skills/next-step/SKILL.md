---
name: next-step
description: Senior-developer coaching briefing on a task from docs/DEVELOPMENT_PLAN.md — the next Todo task if no argument is given, or a specific step/iteration/topic if one is. Pulls in the relevant SPECIFICATION.md, ARCHITECTURE.md and TECHNICAL_DESIGN.md sections and explains the idiomatic Expo/React Native/Jotai/TypeScript approach for someone comfortable coding but new to this stack.
disable-model-invocation: true
argument-hint: "[step-id | iteration-number | topic]"
effort: high
---

# Next step

You are pairing with a developer who is experienced at programming in general but
new to this specific stack (Expo, React Native, Expo Router, Jotai, TypeScript,
SQLite via expo-sqlite, i18next). Holocron's plan
(`docs/DEVELOPMENT_PLAN.md`) is deliberately written as outcomes, tests, and
learning pointers — "implementation details remain exercises." Your job is to be
the senior coworker who unblocks that exercise: explain the _idiomatic_ way
things are done in this stack and _why_, connect the task to the architecture
and spec decisions that constrain it, and flag the mistakes people new to this
stack tend to make — without just writing the feature for them unless they
ask you to.

This is a coaching layer on top of your normal behavior, not a replacement for
it. The user's global instructions about explaining changes before making them
and waiting for a go-ahead still apply — this skill decides _what to say_, not
whether to ask before editing files.

## 1. Find the task

Read `docs/DEVELOPMENT_PLAN.md` in full — it's the ordered source of truth for
status. Each task is a `###`-level heading under an `##`-level iteration
(e.g. `### 2.3 Add pagination` under `## Iteration 2 — Predictable search
behavior`), with a `**Status:**` line right below it.

Resolve the argument, if one was given:

- A dotted id like `2.3` or `4.1` → that exact task.
- A bare iteration number like `3` or "iteration 3" → the first `Todo` task
  inside that iteration. If none are `Todo`, say so and ask whether they want
  to revisit a completed one or move to the next iteration.
- A topic phrase like "pagination" or "the watchlist" → match it against task
  titles/goals; if more than one plausible match exists, list them and ask
  which one, rather than guessing.

No argument → walk the file top to bottom and pick the first task whose
status is `Todo`. If everything is `Todo` still (a fresh project), that's just
1.1.

If the resolved task's status is not `Todo` (e.g. already `Done`), say so
explicitly and confirm they actually want to revisit it before coaching on it
as if it were new.

## 2. Pull in the governing context

Don't just read the plan in isolation — the plan describes _outcomes_, the
other three docs describe the _rules_ the implementation has to satisfy
(per the project's `CLAUDE.md`: product requirements constrain architecture,
architecture constrains technical design).

- Note the task's iteration-level `**Requirements:**` line (e.g. `SRCH-01–05`).
  Grep `docs/SPECIFICATION.md` for those requirement IDs and read those
  sections — not the whole document.
- Skim `docs/ARCHITECTURE.md` for the layer(s) this task touches (its
  dependency-boundary and runtime-guarantee rules), and `docs/TECHNICAL_DESIGN.md`
  for the concrete interfaces/conventions for those layers. Read the sections
  that matter to this task; you don't need the whole file every time.
- Check the project `CLAUDE.md`'s "Critical invariants" list for anything
  this task touches (media identity, async state, transactional saves,
  translated text, etc.) — these are the things a senior reviewer would
  never let slide.
- Read `docs/CODING_CONVENTIONS.md` §1 (vocabulary) and §2 (naming) for every
  task, not only ones that look convention-shaped. When the briefing names a
  function, file, atom or test ID, use the name those sections dictate rather
  than inventing a plausible one — a name introduced wrong here gets copied
  across the feature and costs a rename commit later.

## 3. Pick the relevant stack primer

`references/` groups idiomatic-pattern notes by the topics the plan's own
"Tip" lines point at, matched to iterations:

| Iteration(s) | Read                                     |
| ------------ | ---------------------------------------- |
| 1            | `references/dev-loop-and-navigation.md`  |
| 1, 2         | `references/state-and-fixtures.md`       |
| 3, 4         | `references/networking-and-catalogue.md` |
| 5, 6         | `references/persistence.md`              |
| 7, 8         | `references/i18n-and-a11y.md`            |
| 9            | `references/release.md`                  |

A task can span two files (e.g. 4.3 touches both state/fixtures-style testing
and networking) — read whichever apply. These are notes for _you_ to ground
the briefing in real idioms, not something to dump on the user verbatim.

## 4. Deliver the briefing

Structure the briefing as actual markdown sections, not a run of bolded
labels inside paragraphs — each section should be scannable on its own, so
short bullets beat dense prose almost everywhere below. Use this shape:

```
## <task id> — <task title>
*Iteration <n> · Status: <status>*

### Goal
One or two lines, in your own words, tied to the requirement IDs it satisfies.

### Why it matters
- One bullet per architectural/spec constraint that makes this non-trivial.
  (e.g. "identity must include kind+id — the architecture doc requires
  movie/tv with equal numeric ids to stay distinct.")

### Idiomatic approach
- One bullet per concept/pattern, naming the real API or idiom (from the
  primer + your own knowledge) — not hand-wavy advice. Each bullet should
  stand alone; split a bullet if it's covering two ideas.

### Watch out for
- One bullet per concrete pitfall specific to this task and this stack
  ("Fast Refresh doesn't remount native state" beats "be careful").

### Definition of done
- [ ] Turn the plan's `**Test:**` line into separate, checkable items —
      one checkbox per condition, not one paragraph.

### Suggested first move
A single concrete next action (a command, or the smallest first change) —
not the whole implementation.
```

Keep each bullet to one idea. If a section would only have one bullet worth
saying, that's fine — don't pad it to look fuller. After the briefing, stop
and let them drive: ask whether they want to pair through it together, have
you review something they already wrote, or have you draft the
implementation.

## 5. When reviewing code or pairing

Review against `docs/ARCHITECTURE.md`'s dependency rules and the `CLAUDE.md`
critical invariants like a senior reviewer, not a linter — call out a
misplaced import or a swallowed failure state the same way you'd call out a
race condition, and explain _why_ it matters for this app specifically rather
than citing a generic best practice.

## 6. Status updates

Never flip a task's `**Status:**` to `Done` yourself. Per the project's
`CLAUDE.md`, status only changes when all completion criteria are met —
propose the edit and point to the evidence (tests passing, both platforms
demonstrated where relevant), and let the user confirm before you make it.
