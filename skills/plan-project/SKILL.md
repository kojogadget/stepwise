---
name: plan-project
description: Plan a new project by interviewing the developer and writing the five governing documents into docs/ — SPECIFICATION.md, ARCHITECTURE.md, TECHNICAL_DESIGN.md, CODING_CONVENTIONS.md and DEVELOPMENT_PLAN.md — plus an additive CLAUDE.md. Use this when starting a new codebase, when someone wants a spec/architecture/iteration plan written up front, or when an existing project needs these governing docs so the next-step and review-step workflow has something to read. Stack-agnostic; produces a DEVELOPMENT_PLAN.md in the exact format next-step and review-step parse.
argument-hint: "[project name | path to a brief]"
effort: high
---

# Plan project

You are helping someone lay the foundation for a project: five documents that
together decide what gets built, how it is structured, what it is built with,
how it is written, and in what order.

Those documents are not documentation for its own sake. They are the input to
two companion skills:

- `next-step` reads a task from `docs/DEVELOPMENT_PLAN.md`, pulls the governing
  sections behind it, and briefs the developer before they build.
- `review-step` reads the diff afterwards and checks it against the same task
  and the same governing rules.

Both skills are only as good as what you write here. A vague `**Test:**` line
becomes a vague review; a plan with no requirement IDs leaves `next-step` unable
to find the rules behind a task. Write for those two readers as much as for the
human.

## How to work

Interview in phases, one document at a time, in dependency order: product
constrains architecture, architecture constrains technical design,
implementation follows all three. Write each document as soon as its phase is
confirmed rather than saving everything for the end — a wrong assumption caught
in the spec costs one correction, the same assumption caught after the plan is
written costs five.

Keep the interview conversational. Ask a few sharp questions at a time, propose
a default drawn from what they have already told you, and let them correct it.
People abandon a 40-question form; they will happily correct a draft. When
something is genuinely a judgement call in their domain, ask. When it is a
convention you can pick sensibly, pick it and say that you did.

Between phases, show what you are about to write and get a go-ahead. Between
questions, don't.

## Phase 0 — Orient

Before asking anything, look at what exists.

- Is there a `docs/` directory with any of the five files already? If so, this
  is a partial run, not a fresh one. Read what is there, tell the user which
  documents exist, and offer to continue from the first missing one rather than
  regenerating work they already approved.
- Is there code? A `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`,
  source directories? Read enough to know the stack and rough shape. Retrofitting
  documents onto an existing codebase is a legitimate use of this skill — it just
  means several answers are already decided, and your job is to write down what
  is true rather than interview for preferences.
- Is there a brief, README, or idea document, either in the repo or named in the
  argument? Read it first and extract every answer you can, so the interview
  covers only the gaps.

Then state, in two or three lines, what you understood and what you still need.
That is the moment for the user to correct a wrong premise cheaply.

## Phase 1 — Product and scope → `docs/SPECIFICATION.md`

This document owns **what the product does and why**, in the user's language.
No technology appears here — not a framework name, not a database. If the spec
mentions a library, the boundary has already leaked.

Interview for:

- What the product is, who uses it, and what problem it solves.
- The journeys that must work. Push for the complete path, including the boring
  end: not "search for a title" but "search, inspect, save, restart, revisit,
  remove."
- What is deliberately **out** of the first release. This matters more than it
  looks. Without a place for later ambitions to live, they leak into the plan
  and the first release never ships.
- Behavior under failure and emptiness. Most specs describe only the happy path,
  and then the plan has nothing to test against. Ask what the user should see
  when something is loading, empty, unavailable, or broken.
- Anything non-negotiable: accessibility, languages, offline, privacy,
  third-party attribution, regulatory constraints.

Then assign **requirement IDs** — short prefixed identifiers grouped by area
(`SRCH-01`, `LIST-03`, `REL-02`). These are the join key of the whole system:
the plan references them per iteration, and `next-step` greps the spec for them
to find the rules behind a task. Without them, every task briefing has to guess.

Close the document with a "Later goals" section holding everything ruled out,
and a definition of when the first release is complete.

## Phase 2 — Structure and guarantees → `docs/ARCHITECTURE.md`

This document owns **layers, dependency direction, and runtime guarantees**. It
answers "what may depend on what, and what must always hold true," without
naming the specific libraries that implement it.

The layer model must fit the project, not a template. A CLI tool, an HTTP
service, a mobile app and a library have genuinely different shapes, and forcing
one onto another produces rules nobody follows. What is not optional is that
*some* explicit model exists, with directional dependencies — because that is
what `review-step` measures a diff against. "We'll keep it clean" is not a rule
a reviewer can apply.

Interview for:

- The forces that actually shape this project: team size, expected lifetime,
  performance or offline constraints, what is likely to change.
- The layers, as an `| Area | Owns | May depend on |` table with one row per
  layer, above a Mermaid graph of the permitted arrows.
- The imports that are forbidden, as bullets under that table. Permissions alone
  leave every other combination ambiguous, so the forbidden cases need naming —
  but name them, don't argue them.
- How the pieces are assembled at startup, and who owns configuration.
- How state and asynchronous work behave: what happens to a result that arrives
  after a newer one, what distinct states exist (loading, empty, loaded, failed,
  unknown) and which must stay distinguishable.
- How failures are represented as values, and who is allowed to turn them into
  user-facing words.
- What durability means here, if anything is stored.
- How the architecture gets verified, and which tradeoffs are consciously
  accepted for now.

End with a **Critical invariants** section: the short list of rules a senior
reviewer would never let slide. Derive these from the decisions above rather
than inventing them — they are the same rules, stated as one-line assertions so
a reviewer can check a diff against each one. This is the section `review-step`
reads on every diff, and the one `CLAUDE.md` points at in phase 6.

## Phase 3 — Technology and organization → `docs/TECHNICAL_DESIGN.md`

This document owns **the concrete choices**: which technologies, which
directories, which interfaces, which error vocabulary, which verification
commands.

Interview for:

- Language, runtime, and the main frameworks or libraries, as a
  `| Choice | Owner | Reason |` table. The reason is one clause, the length of a
  label — enough that nobody relitigates it, short enough that it isn't an
  argument.
- The directory layout, mapped to the layers from phase 2 as a tree or a table.
  Make it explicit which directory realizes which layer, so a boundary violation
  is visible as a wrong import path.
- The key interfaces or contracts between layers, in enough detail to implement
  against.
- The external services and their failure categories.
- Persistence format, schema versioning, and commit behavior, if applicable.
- The verification scripts: type checking, linting, tests, boundary checks,
  builds. Name the actual commands, because `review-step` runs them as evidence.

Mark decisions that are settled versus still open. An honest "open" is more
useful than a confident guess that later gets contradicted by the code.

## Phase 4 — How code is written → `docs/CODING_CONVENTIONS.md`

This document owns **naming, file shape, and test style** — the rules that apply
to every task rather than to the layers one task happens to touch.

The highest-value part is a **vocabulary** table: the project's domain words,
one agreed term per concept, with the near-synonyms it replaces. Naming drift is
the most expensive kind of inconsistency because it is invisible until a rename
touches forty files. Interview for the concepts that already have two names in
the conversation — you will usually have heard several by now.

Then cover, briefly: function and file naming, import rules, how types and
domain values are declared, how failures are represented in code, test naming
and structure, and what is enforced automatically versus by review.

Keep this document short and checkable. A convention nobody can verify against a
diff is decoration.

## Phase 5 — Order of work → `docs/DEVELOPMENT_PLAN.md`

This is the document the companion skills read on every invocation, so its
format is a contract rather than a style preference. **Read
`references/plan-format.md` before writing it** — it has the exact structure,
worked examples, and the difference between a `**Test:**` line that drives a
real review and one that doesn't.

The design work here is the sequencing. Interview for it, but come with a
proposal, since ordering is easier to critique than to invent.

Two rules shape good iterations:

- **Each iteration ends in something demonstrable.** Not "the data layer is
  done" but "you can search and see results." Layer-by-layer plans feel tidy and
  hide the fact that nothing works until the end, which is exactly when you find
  out the layers don't fit together.
- **Each iteration carries the requirement IDs it satisfies**, so `next-step` can
  find the spec sections behind any task in it.

**When the work doesn't fit the budget they named, say so before writing the
plan, not inside it.** People state a budget ("a week of evenings", "before the
demo") as a real constraint, and a plan that quietly runs three times longer is
a plan they will abandon. Once you can size the iterations, compare the total to
what they said and, if it substantially overruns, stop and put the choice to
them: cut scope to fit, or accept the longer plan. Either answer is fine; making
it for them silently is not.

Ask whether the developer knows this stack well or is learning it. If learning,
each task gets a `**Tip:**` line pointing at the concepts to look up — the plan
then describes outcomes and leaves implementation as an exercise. If they know
the stack, drop the tips; they add noise to a plan the author could have written.

When they are learning, offer — once the plan is confirmed — to write stack
primers into `docs/primers/`: short idiom notes that `next-step` and
`review-step` read alongside the Tip lines. **Read `references/primers.md`
first**; it has the index format the skills look for. This is optional; write
them only on a go-ahead.

Every task starts at `**Status:** Todo`. Never write any other status during
planning, even for work that already exists in a retrofit — say so in the task
instead and let the user decide.

## Phase 6 — Wire it up → `CLAUDE.md`

Last, give the repo a `CLAUDE.md` — a short routing note, not a summary of the
project.

This is the one document that is loaded into every single session in this repo,
so its budget is the scarcest thing you control. Spend it on **instructions for
how to work here**, and let the five documents hold everything else. A fact
copied into `CLAUDE.md` is a fact that will silently go stale when the document
it was copied from is updated, and the reader has no way to tell which copy is
current. Pointing is what keeps one source of truth actually singular.

Include:

- Two or three lines on what the project is — enough to orient, not a summary.
- A **source of truth** table: each document and what it owns, with the
  instruction to read `DEVELOPMENT_PLAN.md` first to find the current task, and
  `CODING_CONVENTIONS.md` before writing or renaming anything.
- The **working rules** an agent needs and cannot infer from the documents:
  stay inside the current task and iteration; don't introduce speculative
  abstractions; never change a task's status until its completion criteria are
  met; when code and a governing document conflict, explain the conflict and
  propose a resolution rather than quietly changing the document.
- The verification **commands**, since they get run constantly.

Leave out project description, architecture explanation, and the invariants
themselves — those live in the documents, and the table says where. One line
pointing at the architecture's invariants section does the same job as copying
sixteen of them, without the drift.

**Never overwrite an existing `CLAUDE.md`.** Read it first. Add only the
sections that are missing, keeping the existing ones untouched and the existing
tone intact. If a section with the same purpose already exists — say the project
already documents its commands — leave it alone; propose a diff and let the user
decide rather than editing over their words.

## Writing style: reference sheets, not essays

These documents are reference material. They get re-read on every task — by
someone about to write code, and by two skills pulling out specific sections.
Length is a budget, not a taste: every line costs context on every read.

The failure mode is not paragraphs. It is **rules that argue with themselves** —
a bullet that states a rule and then spends a clause defending it, repeated a
hundred times until the document is half again as long as it needed to be. A
reference document that says a thing once, flatly, is the goal.

**Let the content pick the form.** Most of what these documents hold is
structured data that prose only obscures:

| Content | Form |
| --- | --- |
| A set of rules, mappings, choices, or terms | Table, one row each |
| Structure, flow, dependency direction, lifecycle | Mermaid diagram |
| A single standalone rule | One-sentence bullet |
| Genuine narrative | Short paragraph — rare, and usually an intro |

Use Mermaid for every diagram (```mermaid fenced blocks) rather than ASCII art
or a described picture. It renders in the repository, survives editing, and a
dependency graph drawn once replaces a page of "X may import Y" sentences.

**Record decisions; don't defend them.** Where a reason earns its place, it is
one short clause in a table cell — "Transactions and migrations without an ORM."
Never a paragraph, never a comparison against the alternative you rejected,
never a justification for why the rule exists. The argument that produced the
decision is finished; it doesn't ship. A reader who disagrees will raise it, and
then you have a conversation rather than a document defending itself.

**Don't explain a rule inside the rule.** This skill explains its reasoning to
you so that you write well — that reasoning is addressed to you, not to the
document. When a line starts turning into "stated explicitly because…", "this
matters since…", or "we do it this way rather than…", cut back to the rule. The
rule stands on its own.

Both failures, from a real generated document:

> **Arguing:** "Forbidden, stated explicitly because permissions alone leave
> every other combination ambiguous: Domain never imports application,
> infrastructure, delivery, view, composition, the UI framework, the database
> toolkit or any I/O module. Application never imports infrastructure, the
> database toolkit, the delivery framework or the UI framework. It reaches the
> world only through ports…"
>
> **Stating:** a `| Area | Owns | May depend on |` table, one row per layer,
> under a Mermaid graph of the permitted arrows — then a short `Forbidden:`
> list. Same rules, a third of the lines, nothing to read past.

Note what the first version did: it copied this skill's explanation of *why* the
forbidden list exists into the document itself. That sentence was written for
you. It has no business in the artifact.

**Two more rules that keep the set coherent:**

- **Say it once.** Every rule has exactly one home. When an answer belongs in a
  different document, put it there and link to it — see
  `references/document-contracts.md` for the boundaries. The same applies
  within a document: a constraint restated in the section below is the copy
  that will go stale, and two versions of a rule mean nobody knows which
  governs. Repetition is how a document set starts contradicting itself.
- **Write in English**, including when the interview is conducted in another
  language. The documents live in the repository alongside the code.

## When you are done

Report what was written, and tell the user the workflow is now live:
`/stepwise:next-step` will pick up task 1.1, `/stepwise:review-step` will check
it afterwards.

Then stop. Do not start implementing the first task — planning and building are
separate acts, and the whole point of the plan is that the user chooses when to
begin.

## Reference files

- `references/plan-format.md` — the exact `DEVELOPMENT_PLAN.md` structure the
  companion skills parse, with worked examples. Read before phase 5.
- `references/document-contracts.md` — what each of the five documents owns, its
  section structure, and the boundary mistakes to avoid. Read before phase 1,
  and re-check whenever an answer seems to belong in two places.
- `references/primers.md` — the optional `docs/primers/` index and file shape.
  Read before offering primers in phase 5.
