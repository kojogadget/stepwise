# Verification and release (Iteration 9)

## Integration vs. end-to-end testing

- Integration tests here mean real internal collaborators (repositories,
  ViewModels, storage) wired together without mocking your own layers,
  while still faking the outer boundary (TMDB, images) — that's what
  "guard offline tests against real catalogue and image traffic" is asking
  for even at integration scope, not just in unit tests.
- Maestro (a YAML-driven mobile E2E testing tool) drives the real compiled
  app through actual user journeys (search → details → save → restart →
  revisit → remove) on a simulator/device. It's the right tool for "does the
  whole thing work end to end," not for exercising edge cases — those belong
  in the faster unit/integration layer underneath.
- Requirements traceability: literally map each requirement ID from
  `SPECIFICATION.md` to the test(s) or manual check that proves it, and keep
  that mapping somewhere reviewable (a table in a test-plan doc, or
  annotations near the tests themselves) rather than trusting "I'm pretty
  sure we covered that."

## Build and CI gates

- EAS build profiles (`development`, `preview`, `production` in `eas.json`)
  let you produce a debuggable dev-client build, an internal-distribution
  build for testers, and a store-signed production build from the same
  project config — the idiomatic setup keeps environment-specific values
  (API base URLs, feature flags) in profile-scoped config/env vars rather
  than branching code on `__DEV__` everywhere.
- "Reproducible builds" in practice means: locked dependency versions
  (`npm ci`, not `npm install`, in CI), a pinned Expo SDK/EAS build image,
  and no build-time non-determinism (timestamps embedded in bundles,
  environment-dependent codegen) that would make two builds from the same
  commit meaningfully different.
- Separate test storage/identifiers and no test-only routes/switches in
  production usually means: a build-time flag that excludes debug-only
  routes/dev menus from production bundles (not just hiding them behind a
  runtime check that could still be reached), and a distinct SQLite
  database name/location for CI/E2E runs so they can never collide with or
  corrupt a real user's data on a shared device.

## Distribution

- Store submission (App Store Connect / Google Play Console) requirements
  change over time — verify current requirements at submission time rather
  than trusting older notes, especially around privacy manifests/data
  safety forms, which both stores have tightened in recent cycles.
- After release, the practical follow-through is having an actual place to
  see platform crash reports (App Store Connect / Play Console crash
  dashboards, or a crash-reporting SDK if the project adds one) and
  user-reported issues — set this up before calling the release "verified,"
  not after the first bug report arrives with nowhere to look.
