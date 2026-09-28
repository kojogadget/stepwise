# stepwise

A Claude Code plugin for building a project one verified step at a time.

## Why

Asked to build a whole project, an agent drifts: layers blur, names multiply,
and "done" means "the code exists". stepwise splits the work into small tasks,
each with a checkable Test line, and holds every task to the same five
documents — before it is built and again after. You keep the decisions; the
plugin keeps the bookkeeping honest.

## The loop

1. **Plan** once with `/stepwise:plan-project`. It interviews you and writes the
   governing documents into `docs/`.
2. **Brief** the next task with `/stepwise:next-step`: the idiomatic approach,
   the rules it must honor, the pitfalls and a definition of done.
3. **Build** it — yourself, pairing, or by asking Claude to draft it.
4. **Review** it with `/stepwise:review-step`: completion against the Test and
   Goal lines, quality against the architecture and conventions.
5. **Confirm.** A clean review ends with a proposed Status edit. Answer "yes"
   and the task flips to `Done`; nothing changes status without that yes.

When the plan itself turns out wrong, `/stepwise:revise-plan` changes it and
the loop carries on.

## Commands

| Command | Does |
| --- | --- |
| `/stepwise:plan-project [name \| brief]` | Interviews you and writes five governing documents into `docs/`, plus an additive `CLAUDE.md` |
| `/stepwise:next-step [id \| iteration \| topic]` | Briefs the next `Todo` task, or the one you name |
| `/stepwise:review-step [id \| iteration \| topic] [-- evidence]` | Reviews the current diff for that task and proposes, never applies, a Status edit |
| `/stepwise:revise-plan [change]` | Adds, splits, drops or reorders tasks with stable ids; shows a diff and waits |

Only `plan-project` can start on its own when you ask for a project plan; the
other three run only when you invoke them.

The argument picks the task:

| Argument | `next-step` | `review-step` |
| --- | --- | --- |
| none | First `Todo` task in the plan | First `Todo` task, checked against the diff; asks if the diff fits another task better |
| `2.3` | That task | That task |
| `2` | First `Todo` task in iteration 2 | The one task in iteration 2 with changes, otherwise asks |
| `csv import` | Task whose title or goal matches; asks if several do | Same |

`Dropped` tasks are skipped unless named by id. Naming a `Done` or `Dropped`
task makes the skill say so before revisiting it.

## Walkthrough

[`evals/fixtures/tally`](evals/fixtures/tally) is a small word-count CLI planned
with this format — read its `docs/` for what `plan-project` produces. Task 1.1
is `Done`, 1.2 is next:

```text
$ claude                                  # in the tally checkout
stepwise: next task in docs/DEVELOPMENT_PLAN.md is 1.2 Report read failures as values.

> /stepwise:next-step
  ## 1.2 — Report read failures as values
  … Goal, Why it matters, Idiomatic approach, Watch out for,
    Definition of done (four checkboxes from the Test line), Suggested first move

  (you build it and add the tests)

> /stepwise:review-step 1.2 -- ran it on a directory and got a ReadFailure
  … Completion check, Code quality, Verdict: ready to propose Done
  ### Proposed Status edit — apply only after the user confirms

> yes
  (docs/DEVELOPMENT_PLAN.md: 1.2 Todo → Done; the next session starts on 1.3)
```

## Adopting on an existing project

Run `/stepwise:plan-project` in the repository. It reads the code and any
existing `docs/`, writes down what is already true instead of interviewing for
preferences, and continues from the first missing document. For the plan it
asks which shape you want:

- **Remaining work only** — the plan starts at what is still to be built.
- **Full history** — the plan also covers what exists, so requirement IDs trace
  end to end. It lists the tasks it believes are built, with the code that shows
  it, and marks `Done` only those you confirm.

A project can also skip `plan-project` entirely, as long as
`docs/DEVELOPMENT_PLAN.md` follows
[the plan format](skills/plan-project/references/plan-format.md).

## Changing the plan

Use `/stepwise:revise-plan split 2.3`, `drop 3.1`, `add export to iteration 4`
and so on. Ids never change meaning: new tasks are appended with the next free
number, nothing is renumbered, a dropped task stays in place as `Dropped` with
a reason, and `Done` tasks are left alone — rework gets a new task. It also
proposes the matching edits to the specification, architecture and primer
index, shows every change as a diff and writes nothing until you say go.

## Fixing mistakes

Everything stepwise writes is a plain Markdown file in your repository, so git
is the undo.

- **A task marked `Done` too early** — revert the Status line (`git revert` the
  commit, or edit it back to `Todo`), fix the work, and review again. A dotted
  id re-reviews a `Done` task directly: `/stepwise:review-step 2.3`.
- **A plan revision you regret** — revert its commit. If later work depends
  on it, ask `revise-plan` for the opposite change instead.
- **A plugin release you don't like** — the previous behavior is tagged:
  check out `v0.1.0` and load it with `claude --plugin-dir`.

## How it works

### The documents

| Document | Owns |
| --- | --- |
| `docs/SPECIFICATION.md` | Product behavior, requirement IDs, completion criteria |
| `docs/ARCHITECTURE.md` | Layers, dependency direction, runtime guarantees, critical invariants |
| `docs/TECHNICAL_DESIGN.md` | Technologies, directories, interfaces, verification commands |
| `docs/CODING_CONVENTIONS.md` | Vocabulary, naming, file shape, test style |
| `docs/DEVELOPMENT_PLAN.md` | Iterations, tasks, status and Test lines — in a fixed, parsed format |

The plan format is defined in
[`skills/plan-project/references/plan-format.md`](skills/plan-project/references/plan-format.md):
statuses are `Todo`, `Done` and `Dropped`, and requirement ranges like
`ACCT-01–03` expand to every ID in them.

Optional **stack primers** in `docs/primers/` give the companion skills curated
idiom notes when you are learning the stack. See
[`skills/plan-project/references/primers.md`](skills/plan-project/references/primers.md).

### The reviewer agent

`review-step` runs forked in the read-only `step-reviewer` agent. It starts
from a clean context — the code, the diff and `docs/` — so it doesn't anchor on
how the work was described while building it. It can run `git` and the
project's verification commands, but can't edit anything, so it ends with the
proposed Status edit and the main conversation applies it after your yes.

The tradeoff: the reviewer doesn't see the conversation. Anything you checked
by hand counts only if you pass it after `--`:

```sh
/stepwise:review-step 1.2 -- ran it on a directory and got a ReadFailure
```

Where it would need to ask you something, it ends with the question and the
exact command to re-run with the answer.

### The session hook

On startup, resume, `/clear` and compaction, a SessionStart hook prints the
first `Todo` task — id, title and Goal — from `docs/DEVELOPMENT_PLAN.md`, so a
fresh session knows where the plan stands. It is silent when there is no plan
or nothing left to do.

## Install

The repository is its own marketplace, so it installs straight from GitHub. You
need read access to the repository.

```sh
/plugin marketplace add kojogadget/stepwise
/plugin install stepwise@stepwise
```

Update later with `/plugin marketplace update stepwise`.

To try it without installing, clone the repository and start a session with it
loaded:

```sh
claude --plugin-dir path/to/stepwise
```

## Develop

```sh
claude plugin validate .
claude plugin eval . --scaffold \
  --allow-tools 'Bash(git:*)' 'Bash(python -m pytest:*)' Edit Write
```

The cases in `evals/` copy the `evals/fixtures/tally` project into each run's
working directory through their `setup.sh`, hence `--scaffold`. The review-step
cases run git and the fixture's tests, and get Edit so that leaving the plan
untouched is a choice; the plan-project and revise-plan cases get Write and
Edit. Each case is tagged with its skill; run only the next-step cases with
`--tag next-step` and no grant.
