# Stack primers

Primers are optional, project-local notes on the idioms of the project's stack.
`next-step` reads them to ground a briefing in real APIs; `review-step` reads
them to name the idiom a diff is missing. They exist only when the developer is
learning the stack — the same condition that puts `**Tip:**` lines in the plan.

Primers are **not a sixth governing document**. They hold no rules: a rule a
reviewer enforces belongs in the architecture or the conventions, and a primer
may point at it but never restate it.

## Location and index

```
docs/primers/
├── README.md              # the index — the only file the skills look for
├── <topic>.md
└── <topic>.md
```

`README.md` holds one table. The skills match a task against its **Iteration(s)**
and **Topics** columns to pick the files to read:

```markdown
# Stack primers

| Iteration(s) | File | Topics |
| --- | --- | --- |
| 1 | `dev-loop.md` | Dev server, reload, project layout |
| 1, 2 | `state-and-fixtures.md` | State containers, fixtures, test isolation |
```

A primer without a row in the index is invisible to the skills.

## File shape

One file per topic cluster, named after the topic rather than the iteration, so
it survives the plan being reordered.

```markdown
# <Topic> (Iterations <n>–<m>)

## <Idiom or concept>

- What the idiomatic approach is, naming the real API.
- The trap people new to the stack fall into, and what it breaks here.
```

- One `##` section per idiom; bullets under it, one idea each.
- Name real APIs and the version-specific behavior that matters.
- Tie an idiom to this project's architecture when that is the reason for it,
  by pointing at the governing section rather than copying it.
- Keep a file to roughly 50–100 lines. It is read on every matching task.

## Writing them

Group the plan's Tip lines by topic; each cluster becomes one file, and the
iterations its tasks belong to become its index row. Write only what the
developer can't get from a Tip line alone — the idiom and the trap, not a
tutorial.
