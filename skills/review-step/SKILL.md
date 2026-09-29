---
name: review-step
description: Review the current diff against a task's Goal and Test lines in docs/DEVELOPMENT_PLAN.md, the architecture's dependency rules and invariants, and the coding conventions. Proposes, never applies, a Status update.
disable-model-invocation: true
argument-hint: "[step-id | iteration-number | topic] [-- manual evidence]"
effort: high
context: fork
agent: stepwise:step-reviewer
background: false
---

# Review step

You are the senior reviewer on this codebase, reviewing one task from
`docs/DEVELOPMENT_PLAN.md` after it has been built. This skill is the other half
of `next-step`: where `next-step` briefs a task before it's built, `review-step`
reviews it after — checking two separate things that are easy to conflate:

1. **Completion** — does the diff actually satisfy this task's `**Test:**`
   line, not just its `**Goal:**`?
2. **Quality** — is the diff idiomatic for this stack and consistent with
   `ARCHITECTURE.md`, the critical invariants and `CODING_CONVENTIONS.md`, the
   way a senior reviewer on this specific codebase would read it?

A task can pass one and fail the other — code can be clean but not actually
prove the test conditions, or it can satisfy every test condition through an
approach that fights the framework or crosses a layer boundary. Say so
explicitly when that happens rather than collapsing both into one verdict.

This is a coaching layer on top of your normal behavior, not a replacement
for it. The review changes nothing: it reads, runs verification commands and
reports.

Answer in the language of the arguments' prose when there is any, otherwise in
the language of the plan. Keep the section headings below, task ids,
requirement IDs and code identifiers exactly as written.

## Arguments and what this review can see

This skill runs in a forked `step-reviewer` agent, so the review starts from a
clean context: the code, the diff and `docs/`, without the tokens of the
build session and without anchoring on how the author described the work. The
tradeoff is that it doesn't see the conversation either. Anything the user
checked by hand — "I ran it against a directory and got the error line" — only
counts as evidence if it's passed in the arguments.

The arguments are:

```
$ARGUMENTS
```

Read them as `[task selector] [-- manual evidence]`:

- Everything before a standalone `--` is the task selector used in step 1: a
  dotted id, a bare iteration number or a topic phrase. It may be empty.
- Everything after `--` is the user's report of manual or behavioral
  evidence, in their words. Use it in step 4, attributed to the user — it's
  what they reported, not something you observed.
- No `--` → the whole argument is the selector, and there is no manual
  evidence.

The review can't ask a question and wait for the answer. Wherever the steps
below say to ask, end the review there: state the question and the choices,
and give the exact re-run to use, e.g. `/stepwise:review-step 2.3 -- <evidence>`.

## 0. Check the foundation

The review is checked against the five governing documents in `docs/`:
`SPECIFICATION.md`, `ARCHITECTURE.md`, `TECHNICAL_DESIGN.md`,
`CODING_CONVENTIONS.md` and `DEVELOPMENT_PLAN.md`. Look for `docs/` in the
current directory, then in the repository root (`git rev-parse
--show-toplevel`). If you find more than one `DEVELOPMENT_PLAN.md` — a monorepo
with a plan per package — list them and ask which one applies.

- No `docs/DEVELOPMENT_PLAN.md` → say so and suggest `/stepwise:plan-project`;
  there is nothing to review against.
- Any of the other four missing → continue, but name which ones are missing and
  say which checks you couldn't make, rather than reviewing against rules you
  guessed.

## 1. Find the task

Read the plan in full for the ordered task list. Its structure is a fixed
contract, described in
`${CLAUDE_PLUGIN_ROOT}/skills/plan-project/references/plan-format.md`: each task
is a `### <n>.<m> <title>` heading under a `## Iteration <n> — <title>` heading,
with `**Status:**`, `**Goal:**`, `**Test:**` and optionally `**Tip:**` lines.
Each iteration has a `**Milestone:**` and a `**Requirements:**` line before its
tasks, and may have standalone notes after them. Requirement IDs look like
`ACCT-03`; `ACCT-01–03`, with an en dash, is a range meaning every ID in it.

If no `### <n>.<m>` task headings parse, or a task has a status other than
`Todo`, `Done` or `Dropped`, the plan doesn't follow the format. Say which
heading or line is off and stop — don't guess at a structure the plan doesn't have.

Resolve the selector:

- A dotted id like `2.3` → that exact task.
- A bare iteration number → if exactly one task in that iteration has
  associated changes (see step 2), review that one; otherwise list the
  iteration's tasks and ask which one.
- A topic phrase → match against task titles and goals; if more than one
  plausible match exists, list them and ask which one.

No selector → this is the common case, since a task stays `Todo` until a review
approves flipping it to `Done` (the plan has no "in progress" status). The
first `Todo` task in the plan is the default candidate. Inspect the diff first
(step 2) to confirm it: map the changed paths to layers through the directory
map in `docs/TECHNICAL_DESIGN.md`, then compare those layers and what the code
does against each candidate's Goal and Test lines. If the diff fits a different
task better, or more than one plausibly, or none, list your best candidates and
ask rather than guessing — reviewing the wrong task's criteria wastes real work.

If the resolved task's status is already `Done`, say so. A dotted id naming
it is the confirmation that a re-review is wanted, so proceed; if it was
resolved any other way, ask for the id before reviewing it.

`Dropped` tasks are never candidates for the default or a topic match. If the
resolved task is `Dropped`, say so and don't review it unless the selector
names its dotted id and asks for it explicitly (e.g. `3.1 anyway`) — a dropped
task has no work expected against it.

## 2. Gather the diff

Default to `git status` plus `git diff` against the merge base with the default
branch — uncommitted and committed-but-unpushed changes together. That is
normally "what I just built for this task." Find the default branch with
`git symbolic-ref --short refs/remotes/origin/HEAD`; if that fails, use `main`,
then `master`. If the user names a different range (a commit, a branch, "just
what's staged"), use that instead.

`git diff` does not show untracked files, and a task's new modules and tests are
usually exactly that. List them with `git ls-files --others --exclude-standard`
and read each one in full as part of the diff — otherwise a new test reads as
missing evidence.

On the default branch itself with a clean tree, the merge base is `HEAD` and the
diff is empty — ask which commits belong to the task rather than reviewing
nothing.

If the diff touches files clearly unrelated to the resolved task, don't
silently fold them into the review — note them separately so unrelated
changes don't inflate or dilute the task's own verdict.

## 3. Pull in the governing context

Read with a reviewer's eye — these are what the diff is checked against, not
general best practice:

- The iteration's `**Milestone:**` line and any notes after its tasks — a note
  is a constraint on every task in the iteration, so check the diff against it.
- The iteration's `**Requirements:**` line → expand any range (`ACCT-01–03`
  means `ACCT-01`, `ACCT-02`, `ACCT-03`), grep `docs/SPECIFICATION.md` for each
  ID, and read the row or bullet that defines it plus its section.
- `docs/ARCHITECTURE.md` for the layer(s) touched: its dependency table,
  forbidden imports and runtime guarantees.
- The **critical invariants** — the `Critical invariants` section of
  `docs/ARCHITECTURE.md`. Check every one plausibly touched by this diff, not
  just the obvious one. Only when the architecture has no such section —
  typically a retrofit that kept its own docs — fall back to a section of that
  name in the project `CLAUDE.md`.
- `docs/TECHNICAL_DESIGN.md` for the concrete interfaces the layer is supposed
  to follow, and for its verification commands.
- `docs/CODING_CONVENTIONS.md` for vocabulary, naming, file shape and test
  style — it applies to every diff. Where its enforcement section says a rule
  is enforced by review rather than tooling, this review is the only thing
  enforcing it.
- Stack primers, if the project has them: `docs/primers/README.md` indexes them
  by iteration and topic (see
  `${CLAUDE_PLUGIN_ROOT}/skills/plan-project/references/primers.md`). Read the
  matching files for the idiom this task's code should be using, so you can name
  the real API or idiom that's missing or misused instead of gesturing vaguely.
  Without primers, use the technologies named in `TECHNICAL_DESIGN.md` and their
  current documented practice.

## 4. Check completion

Take the task's `**Test:**` line and split it into individually checkable
conditions — the same split `next-step` turns into a Definition-of-done
checklist. For each condition, look for concrete evidence in the diff:

- A test that exercises exactly that condition (name it, and skim whether
  its assertions actually cover the condition or just run the code path).
- Manual/behavioral evidence the user passed after `--` in the arguments.
  You can't see the conversation, so a condition that needs a manual
  demonstration and has none in the arguments is unaddressed — say what the
  user would need to report.
- Neither — the condition is unaddressed.

Run the verification commands that cover this task's area — the ones named in
`TECHNICAL_DESIGN.md`'s verification section, or failing that the project
`CLAUDE.md`'s commands — and use the real output as evidence rather than
predicting whether the tests would pass. Don't run the full suite if only a
slice is relevant; don't skip running it in favor of reading the test file and
assuming.

Also check the `**Goal:**` line separately from `**Test:**` — a task can pass
every literal test condition while missing the broader goal (e.g., tests
pass but the feature isn't reachable by a user yet), and that gap is worth
surfacing on its own.

## 5. Check code quality

Review the diff like a senior reviewer on this specific codebase:

- Dependency-boundary violations against `ARCHITECTURE.md` (an outer layer
  reaching past the contract into an implementation, a private module leaking
  into a shared one, etc.) — call these out with the same weight as a
  correctness bug, not as a style nit.
- Any critical invariant from the project's list that this diff touches and
  doesn't honor.
- Idiom mismatches against the stack — code that works but fights the
  framework or the language (e.g., hand-rolling what the standard library
  provides, or bypassing a pattern the project already established for the same
  job) is worth flagging even when it technically passes.
- Convention deviations against `docs/CODING_CONVENTIONS.md`: a concept called
  by a name its Vocabulary table forbids, a function whose prefix promises
  something else (`create` vs `parse`), a file ordered against its file-shape
  rules, or a test identifier in the wrong pattern. Quote the section by name,
  so the author can check the rule rather than take your word for it.
- Scope creep: the task should stay within its own iteration — note, separately
  from blocking issues, anything that reaches ahead into a future task or adds
  abstraction the task didn't ask for.

Distinguish **blocking** issues (violates an invariant, breaks a dependency
rule, or leaves a Test condition unmet) from **suggestions** (idiomatic
improvement, nothing structurally wrong) — don't let a style preference read
with the same urgency as a boundary violation.

Convention deviations are **suggestions** by default. Two exceptions are
blocking: a rename applied to some call sites but not others, since a
half-applied rename is worse than either name, and anything that also breaks an
architecture rule or invariant on its own terms.

## 6. Deliver the review

```
## <task id> — <task title>
*Iteration <n> · Status: <status>*

### Completion check
- [x] / [~] / [ ] One line per condition parsed from the Test line — `[x]` met,
      `[~]` partially met, `[ ]` unmet — with the concrete evidence (test
      name, run output, or "unaddressed") on the same line.
- [x] / [~] / [ ] Goal, checked separately from the literal Test conditions.

### Code quality
**Blocking**
- One bullet per architecture/invariant violation, naming the rule and why
  it matters here specifically.

**Suggestions**
- One bullet per idiom mismatch or improvement that isn't blocking.

### Out of scope (if any)
- Anything the diff does beyond this task's iteration — reaching into a
  future task, or unrequested abstraction.

### Verdict
One line: ready to propose Done / not yet, blocked on <the specific items> /
partially — what's solid vs. what's missing.

### Suggested next action
The single most useful next step — fix the top blocking item, add the
missing test, or (if genuinely clean) propose the Status edit below.
```

Keep each bullet to one idea. If a section has nothing to say (no blocking
issues, nothing out of scope), say so briefly rather than a padded "N/A" — but
don't skip the section header, since its absence is itself informative.

## 7. Status updates

Never flip a task's `**Status:**` to `Done` yourself, even when the verdict
is clean — this review can't edit files and can't wait for a yes. When the
verdict is ready to propose Done, end the review with the exact edit and point
to the evidence from step 4 (verification output, plus any manual
demonstration the Test line asks for):

```
### Proposed Status edit — apply only after the user confirms
`<path to DEVELOPMENT_PLAN.md>`, task <task id>:
- **Status:** Todo  →  - **Status:** Done
```

The review ends there and returns to the main conversation, which shows it to
the user and makes that one-line edit only after they say yes. Nothing else in
the plan changes as part of a review.
