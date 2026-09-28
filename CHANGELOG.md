# Changelog

All notable changes to this plugin are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the plugin follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-09-28

### Added

- `Dropped` task status for work abandoned on purpose. It stays in the plan so
  its id is never reused; `next-step` and `review-step` skip it unless it is
  named by id.
- `/stepwise:revise-plan` adds, splits, drops and reorders tasks with stable
  ids, proposes matching edits to the specification, architecture and primer
  index, and shows a diff before writing anything.
- Retrofit mode in `plan-project`: plan only the remaining work, or the full
  history with already-built tasks marked `Done` once you confirm them.
- `review-step` runs forked in a read-only `step-reviewer` agent, starting from
  a clean context. Manual evidence is passed after `--`, e.g.
  `/stepwise:review-step 1.2 -- ran it on a directory`, and the review ends with
  a proposed Status edit that is applied only after you say yes.
- A SessionStart hook prints the next `Todo` task on startup, resume, clear and
  compaction.
- `next-step` and `review-step` stop and name the offending line when the plan
  doesn't parse, report missing governing documents, and ask when a monorepo has
  several plans.
- Eval cases for explicit ids, `Done` and `Dropped` tasks, primers, a clean
  review, a convention suggestion, a partial `plan-project` run and
  `revise-plan`.
- README sections on the loop, a walkthrough, adoption, revising the plan and
  recovering from mistakes; complete manifest metadata.

### Changed

- The plan format defines requirement ID syntax (`ACCT-03`) and en-dash ranges
  (`ACCT-01–03`), which the skills expand before searching the specification.
  Each ID is defined once in the specification, as a table row or bullet lead.
- `next-step` and `review-step` read the iteration's Milestone line and the
  notes after its tasks; the plan's Working rules section is gone, since
  `CLAUDE.md` holds working rules.
- `review-step` matches the diff to a task through the layers of the changed
  paths, starting from the first `Todo` task.
- Critical invariants live only in `ARCHITECTURE.md`; the `CLAUDE.md` fallback
  remains for retrofits whose architecture has no such section.
- `plan-project` triggers only for whole-project planning, and points at
  `document-contracts.md` for document shape instead of restating it.
- The companion skills answer in the conversation's language and keep headings
  and identifiers verbatim.
- Examples left over from the original project are replaced with neutral ones.

### Fixed

- `review-step` reads untracked files, so new modules and tests count as
  evidence.
- The completion check defines `[x]`, `[~]` and `[ ]` for met, partially met and
  unmet.
- The reason-column rule is consistent across the reference documents.
- The Mermaid example in the document contracts renders inside its outer fence.

### Compatibility

The plan format is extended, not changed: a plan written for 0.1.0, with only
`Todo` and `Done`, still parses. A leftover `### Working rules` section doesn't
break parsing, but no skill reads it and `plan-project` flags it as drift; move
its rules into `CLAUDE.md`.

## [0.1.0] - 2026-09-28

Baseline release.

- `plan-project`, `next-step` and `review-step` skills.
- Project-local stack primers in `docs/primers/`.
- The repository as its own marketplace, and plugin eval cases.

[0.2.0]: https://github.com/kojogadget/stepwise/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/kojogadget/stepwise/releases/tag/v0.1.0
