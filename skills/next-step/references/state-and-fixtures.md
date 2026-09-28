# State, fixtures, and architecture enforcement (Iterations 1–2)

## Jotai outside React

- The idiomatic reason to reach for Jotai here (per the architecture doc's
  "ViewModels as vanilla Jotai atom bundles, testable without rendering") is
  that atoms are plain values you can read/write/subscribe to with a
  `createStore()` instance and no React tree at all. A ViewModel is then just
  a bundle of atoms plus the functions that update them — you can unit test
  it by creating a store, calling a function, and reading an atom back,
  with zero rendering involved.
- The trap people coming from Redux/MobX fall into: creating atoms at module
  scope and mutating global default-store state directly from tests, which
  makes tests leak state into each other. Create a fresh `Store` per test
  (or per ViewModel instance in composition) and pass it in explicitly —
  that's also what "explicit application store" in the architecture doc is
  pointing at.
- Derived/computed atoms (`atom(get => ...)`) are the idiomatic way to get
  "derived state" for things like a computed filtered list — don't
  hand-roll a `useEffect` that copies one atom's value into another.

## Repository contracts and immutable domain values

- A repository contract here is a TypeScript interface owned by the domain
  layer; the sample-data implementation and the future TMDB implementation
  both satisfy it. Presentation and ViewModels depend on the interface, not
  the concrete implementation — that's the dependency-inversion the
  architecture doc is enforcing, and it's what makes swapping fixtures for
  live TMDB calls in iteration 3 a non-event for the UI layer.
- "Published domain values cannot be changed by consumers" means: don't
  return mutable objects/arrays from the domain layer and trust callers not
  to mutate them. Use `readonly` fields, `ReadonlyArray<T>`, and prefer
  returning new objects over exposing setters. This is also exactly what
  protects "movie/TV identity stays distinct even with equal numeric IDs" —
  identity should be a value object (e.g. `{ kind: 'movie' | 'tv', id: number }`)
  compared structurally, not just a bare number used as a map key (a bare
  numeric key silently collides between a movie id and a TV id that happen
  to match).

## Fixtures and testing idioms

- Fixtures are deterministic, hand-written sample data living alongside the
  tests (or in a shared `fixtures/` module) — not randomly generated and not
  hitting the network. Keep them even after TMDB is wired up in iteration 3;
  the plan explicitly calls for retaining fixtures for testing, so live
  service tests and unit/fixture tests stay separate.
- **Debouncing + fake timers** (2.1): use Jest's fake timers
  (`jest.useFakeTimers()`, `jest.advanceTimersByTime(ms)`) to assert on the
  300ms threshold deterministically instead of real `setTimeout` waits in
  tests — real waits make tests slow and flaky. The idiomatic debounce
  implementation restarts its timer on every keystroke and only fires once
  input has been stable for the threshold; testing "restarted pause after
  further typing" means asserting the request does _not_ fire if you advance
  time partway, type again, then advance the full threshold from that point.
- **Table-driven tests** (2.2): one `it.each([...])` (or equivalent) covering
  all filter × query combinations beats one `it()` per case — it keeps the
  cases readable as data and makes it obvious when a combination is missing.
- **Cursor pagination + dedup** (2.3): treat the identity value object (kind
  - id) as the dedup key across pages, not array index or raw TMDB numeric
    id. "Prevention of simultaneous next-page loads" is a state-machine
    concern — model an explicit `idle | loading-more | error` status on the
    list rather than a loose boolean flag, so a second request can't be fired
    while one is in flight.
- **Race conditions / cancellation** (2.4): the idiomatic guard is a request
  token/generation counter — each new search increments a counter, and when
  a request resolves it only applies its result if its token still matches
  the current one. This is more reliable than relying on `AbortController`
  cancellation alone, since the test scenario explicitly requires correctness
  "even when cancellation is ignored."

## Architecture enforcement

- `dependency-cruiser` is a static analysis tool that reads your actual
  import graph and checks it against rules you declare (e.g. "presentation
  must not import repositories directly"). Configuring it early, and running
  it in CI, turns an architecture doc's prose rules into something that fails
  a build automatically rather than relying on review to catch drift.
- "Impure ViewModels" and "incorrect dependency initialization" being
  rejected usually means: a lint/test rule asserting ViewModels don't import
  React or perform IO directly, and that composition (not the ViewModel
  itself) constructs and injects repositories/adapters — i.e. dependency
  injection at the composition root, not a ViewModel reaching for a
  singleton.
