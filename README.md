# stepwise

A Claude Code plugin for building a project one verified step at a time.

| Skill | Command | Does |
| --- | --- | --- |
| plan-project | `/stepwise:plan-project [name \| brief]` | Interviews you and writes five governing documents into `docs/`, plus an additive `CLAUDE.md` |
| next-step | `/stepwise:next-step [id \| iteration \| topic]` | Briefs the next `Todo` task (or the one you name) against the governing documents |
| review-step | `/stepwise:review-step [id \| iteration \| topic]` | Reviews the current diff against that task's Test and Goal lines, the architecture and the conventions |

`next-step` and `review-step` only run when you invoke them. Neither changes a
task's status; both propose the edit and wait for you.

## The documents

| Document | Owns |
| --- | --- |
| `docs/SPECIFICATION.md` | Product behavior, requirement IDs, completion criteria |
| `docs/ARCHITECTURE.md` | Layers, dependency direction, runtime guarantees, critical invariants |
| `docs/TECHNICAL_DESIGN.md` | Technologies, directories, interfaces, verification commands |
| `docs/CODING_CONVENTIONS.md` | Vocabulary, naming, file shape, test style |
| `docs/DEVELOPMENT_PLAN.md` | Iterations, tasks, status and Test lines — in a fixed, parsed format |

The plan format is defined in
[`skills/plan-project/references/plan-format.md`](skills/plan-project/references/plan-format.md).
A project can adopt the workflow without `plan-project` as long as its plan
follows that format.

Optional **stack primers** in `docs/primers/` give the companion skills curated
idiom notes when you are learning the stack. See
[`skills/plan-project/references/primers.md`](skills/plan-project/references/primers.md).

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
claude plugin eval . --scaffold --allow-tools 'Bash(git:*)'
```

The cases in `evals/` copy the `evals/fixtures/tally` project into each run's
working directory through their `setup.sh`, hence `--scaffold`. The review-step
case also needs git, hence the Bash grant; run only the next-step cases with
`--tag next-step` and no grant.
