---
name: review-step
description: Senior-developer review of an implemented Holocron task from docs/DEVELOPMENT_PLAN.md — checks the current diff against the task's Goal/Test/Requirements lines and against ARCHITECTURE.md/CLAUDE.md invariants and idiomatic Expo/React Native/Jotai/TypeScript style. Companion to the next-step skill: next-step briefs before you build, review-step reviews after you've built. Proposes but never applies a Status update.
disable-model-invocation: true
argument-hint: "[step-id | iteration-number | topic]"
effort: high
---

# Review step

You are pairing with a developer who is experienced at programming in general
but new to this specific stack (Expo, React Native, Expo Router, Jotai,
TypeScript, SQLite via expo-sqlite, i18next). This skill is the other half of
`next-step`: where `next-step` briefs a task before it's built, `review-step`
reviews it after — checking two separate things that are easy to conflate:

1. **Completion** — does the diff actually satisfy this task's `**Test:**`
   line, not just its `**Goal:**`?
2. **Quality** — is the diff idiomatic for this stack and consistent with
   `ARCHITECTURE.md` and the `CLAUDE.md` invariants, the way a senior
   reviewer on this specific codebase would read it?

A task can pass one and fail the other — code can be clean but not actually
prove the test conditions, or it can satisfy every test condition through an
approach that fights the framework or crosses a layer boundary. Say so
explicitly when that happens rather than collapsing both into one verdict.

This is a coaching layer on top of your normal behavior, not a replacement
for it. The user's global instructions about explaining changes before
making them and waiting for a go-ahead still apply.

## 1. Find the task

Read `docs/DEVELOPMENT_PLAN.md` in full for the ordered task list (each task
is a `###` heading under an `##` iteration, with a `**Status:**` line below
it — see `next-step`'s SKILL.md for the exact structure if you need a
refresher).

Resolve the argument the same way `next-step` does:

- A dotted id like `2.3` or `4.1` → that exact task.
- A bare iteration number → if exactly one task in that iteration has
  associated changes (see step 2), review that one; otherwise list the
  iteration's tasks and ask which one.
- A topic phrase → match against task titles/goals; if more than one
  plausible match exists, list them and ask which one.

No argument → this is the common case, since a task usually stays `Todo`
until a review approves flipping it to `Done` (there is no separate
"in progress" status in this plan). Inspect the diff first (step 2), then
match its files/requirement IDs against task titles and iteration scope to
guess the task. If more than one task plausibly matches, or nothing does,
list your best candidates and ask rather than guessing — reviewing the wrong
task's criteria wastes real work.

If the resolved task's status is already `Done`, say so and confirm the user
wants a re-review before proceeding, the same way `next-step` confirms
before re-coaching a finished task.

## 2. Gather the diff

Default to `git status` plus `git diff` against the merge base with `main`
(uncommitted and committed-but-unpushed changes together) — this is normally
"what I just built for this task." If the user names a different range
(a commit, a branch, "just what's staged"), use that instead.

If the diff touches files clearly unrelated to the resolved task, don't
silently fold them into the review — note them separately so unrelated
changes don't inflate or dilute the task's own verdict.

## 3. Pull in the governing context

Same sources `next-step` uses, read with a reviewer's eye instead of a
briefing eye:

- The task's iteration-level `**Requirements:**` line → grep
  `docs/SPECIFICATION.md` for those IDs and read those sections.
- `docs/ARCHITECTURE.md` for the layer(s) touched — its dependency-boundary
  and runtime-guarantee rules are what you're checking the diff against, not
  general best practice.
- `docs/TECHNICAL_DESIGN.md` for the concrete interfaces the layer is
  supposed to follow.
- `docs/CODING_CONVENTIONS.md` for naming, file shape, and test style — it
  applies to every diff, and until the automation in its §9 table exists,
  review is the only thing enforcing it.
- The project `CLAUDE.md`'s "Critical invariants" list — check every one
  that's plausibly touched by this diff, not just the obvious one.
- The matching stack primer from `next-step`'s `references/` directory (see
  its SKILL.md table mapping iterations to files) — read it for the
  idiomatic pattern this task's code should be using, so you can name the
  real API/idiom that's missing or misused instead of gesturing vaguely.

## 4. Check completion

Take the task's `**Test:**` line and split it into the same kind of
individually checkable conditions `next-step` turns into a Definition-of-done
checklist. For each condition, look for concrete evidence in the diff:

- A test that exercises exactly that condition (name it, and skim whether
  its assertions actually cover the condition or just run the code path).
- Manual/behavioral evidence the user has reported in this conversation.
- Neither — the condition is unaddressed.

Where the project's verification scripts are relevant (check `package.json`
per `CLAUDE.md` — type check, lint, unit tests), run the ones that cover this
task's area and use the real output as evidence rather than predicting
whether the tests would pass. Don't run the full suite if only a slice is
relevant; don't skip running it in favor of reading the test file and
assuming.

Also check the `**Goal:**` line separately from `**Test:**` — a task can pass
every literal test condition while missing the broader goal (e.g., tests
pass but the feature isn't reachable from the UI yet), and that gap is worth
surfacing on its own.

## 5. Check code quality

Review the diff like a senior reviewer on this specific codebase, per
`next-step`'s step 5:

- Dependency-boundary violations against `ARCHITECTURE.md` (a presentation
  import reaching into a repository, a feature-private module leaking to
  shared presentation, etc.) — call these out with the same weight as a
  correctness bug, not as a style nit.
- Any `CLAUDE.md` critical invariant this diff touches and doesn't honor
  (media identity, async state ordering, transactional save/remove,
  documented failure types, translation-key text, credential handling).
- Idiom mismatches against the stack primer — code that works but fights
  the framework (e.g., reaching for `useEffect` + local state where a Jotai
  atom belongs, or manual `useState` timers instead of the established
  debounce pattern) is worth flagging even when it technically passes.
- Convention deviations against `docs/CODING_CONVENTIONS.md`: a concept
  called by a name its §1 vocabulary row forbids, a function whose prefix
  promises something else (`create` vs `parse`), a file ordered against §3,
  or a test ID that isn't `<feature>-<element>`. Quote the section, so the
  author can check the rule rather than take your word for it.
- Scope creep: per `CLAUDE.md`, this task should stay within its own
  iteration — note, separately from blocking issues, anything that reaches
  ahead into a future task or adds abstraction the task didn't ask for.

Distinguish **blocking** issues (violates an invariant, breaks a dependency
rule, or leaves a Test condition unmet) from **suggestions** (idiomatic
improvement, nothing structurally wrong) — don't let a style preference read
with the same urgency as a boundary violation.

Convention deviations are **suggestions** by default. Two exceptions are
blocking: a rename applied to some call sites but not others, since
`CODING_CONVENTIONS.md` §1 requires renaming a concept everywhere including
tests and test IDs in the same commit, and anything that also breaks an
architecture rule or invariant on its own terms.

## 6. Deliver the review

```
## <task id> — <task title>
*Iteration <n> · Status: <status>*

### Completion check
- [ ] One checkbox per condition parsed from the Test line — mark it met,
      partially met, or unmet, with the concrete evidence (test name, run
      output, or "unaddressed") on the same line.
- [ ] Goal, checked separately from the literal Test conditions.

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

Keep each bullet to one idea, same as `next-step`. If a section has nothing
to say (no blocking issues, nothing out of scope), say so briefly rather
than a padded "N/A" — but don't skip the section header, since its absence
is itself informative.

## 7. Status updates

Never flip a task's `**Status:**` to `Done` yourself, even when the verdict
is clean. Per the project's `CLAUDE.md` and `next-step`'s own rule, propose
the exact edit and point to the evidence from step 4 (tests passing, both
platforms demonstrated where relevant), and let the user confirm before you
make it.
