---
name: revise-plan
description: Revise docs/DEVELOPMENT_PLAN.md — add, split, drop or reorder tasks with stable ids — and propose the matching edits to the spec, architecture or primer index. Always shows a diff and waits for a go-ahead.
disable-model-invocation: true
argument-hint: "[change, e.g. split 2.3 | drop 3.1 | add export to iteration 4]"
effort: high
---

# Revise plan

You are revising `docs/DEVELOPMENT_PLAN.md` after planning, because the project
learned something: a task turned out to be two, a feature was cut, or the order
no longer makes sense. The plan is read on every invocation of `next-step` and
`review-step`, so a revision has to keep it in the exact format they parse, and
keep every existing task id meaning what it meant before.

Any user or project instructions about explaining changes before making them
and waiting for a go-ahead still apply — and this skill never writes without
one anyway.

Answer in the language of the conversation. Keep task ids, requirement IDs,
headings and code identifiers exactly as written, and write every document
edit in English.

## 0. Check the foundation

Look for `docs/` in the current directory, then in the repository root (`git
rev-parse --show-toplevel`). If you find more than one `DEVELOPMENT_PLAN.md` — a
monorepo with a plan per package — list them and ask which one applies.

- No `docs/DEVELOPMENT_PLAN.md` → say so and suggest `/stepwise:plan-project`.
  There is nothing to revise.
- `SPECIFICATION.md`, `ARCHITECTURE.md` or `docs/primers/README.md` missing →
  continue, but name what is missing and don't propose edits to it.

## 1. Read the plan

Read the plan in full. Its structure is a fixed contract, described in
`${CLAUDE_PLUGIN_ROOT}/skills/plan-project/references/plan-format.md`: each task
is a `### <n>.<m> <title>` heading under a `## Iteration <n> — <title>` heading,
with `**Status:**`, `**Goal:**`, `**Test:**` and optionally `**Tip:**` lines.
Status is `Todo`, `Done` or `Dropped`. Each iteration has a `**Milestone:**` and
a `**Requirements:**` line before its tasks, and may have standalone notes after
them. The approach section has a `**Visible milestones:**` table. Requirement
IDs look like `ACCT-03`; `ACCT-01–03`, with an en dash, is a range meaning every
ID in it.

If no `### <n>.<m>` task headings parse, or a task has a status other than
`Todo`, `Done` or `Dropped`, the plan doesn't follow the format. Say which
heading or line is off and stop — revising a plan the other skills can't parse
only hides the problem.

If the argument doesn't say what to change, ask. If it names a task that
doesn't exist, say so rather than picking the nearest one.

## 2. Keep ids stable

A task id is its identity. It appears in commit messages, review notes and the
user's memory of the project, so an id always points at the same task.

- **Never renumber.** No existing heading changes its `<n>.<m>`, even when a
  gap or an out-of-order number results.
- **Add** → append the task at the end of its iteration with the next unused
  number there. A new iteration gets the next unused iteration number.
- **Reorder** → move the task sections within their iteration, keeping their
  ids; file order is the order `next-step` walks. Whole iterations move the
  same way. To move a task into another iteration, drop it where it is and add
  it at the end of the target iteration under a new id, with a note on the old
  one naming the new id.
- **Split** → the original keeps its id and narrows to the first part; the
  rest become new tasks appended to the iteration. Each part gets its own
  checkable Test line, split from the original rather than rewritten.
- **Drop** → set `**Status:** Dropped` and leave the task in place, with a
  short note saying why. Never delete a task.
- **Done tasks are history.** Don't split, reword or drop a `Done` task. If the
  change means built work must be redone, add a new task for it.

New and changed tasks follow `plan-format.md`: an outcome-shaped Goal, a Test
line with checkable conditions, and a Tip line only if the plan already uses
them.

## 3. Follow the change into the other documents

A plan edit often means a governing document is now wrong. Check, and propose
the matching edit alongside the plan diff:

- **Specification** — a new task that needs behavior no requirement covers
  needs a new requirement ID, appended after the last one with that prefix.
  A requirement whose only tasks are now dropped is out of the first release:
  move it to the out-of-scope section rather than deleting it.
- **Requirements lines** — every iteration's `**Requirements:**` line still
  lists exactly the IDs its non-dropped tasks satisfy.
- **Milestones** — an iteration's `**Milestone:**` line and its row in the
  Visible milestones table still describe what its tasks now deliver.
- **Architecture** — a change that adds a layer, crosses a boundary the
  dependency rules forbid, or touches a critical invariant needs an
  architecture edit. Propose it and name the conflict; never bend the plan
  around the rule silently.
- **Primer index** — if `docs/primers/README.md` exists, its Iteration(s)
  column still matches where the topics are now used.

## 4. Show the diff, then wait

Present the change as a unified diff per file — the plan first, then any other
document — with one line per file on why it changes. Then stop and ask for a
go-ahead. Write nothing before it; apply exactly what was approved, and if the
user amends the proposal, show the amended diff again.

Never change a task's status to `Done` here. That happens through
`/stepwise:review-step`, once its completion criteria are met.
