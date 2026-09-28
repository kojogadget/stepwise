# Internationalization and accessibility (Iterations 7–8)

## i18next resources and interpolation

- Interface strings live in typed translation-key resources (English and
  Bokmål) rather than inline literals — the project's `CLAUDE.md` already
  requires routing UI text through typed keys, which also gives you the
  "message and interpolation parity" check almost for free: a lint/test step
  can diff the key sets of both locale resource files and fail if one has
  keys the other lacks, or if interpolation placeholders (`{{count}}` etc.)
  don't match between them.
- Date/number formatting should go through `Intl.DateTimeFormat` /
  `Intl.NumberFormat` with the active locale rather than hand-formatted
  strings, including for date-only values (careful with timezone: a
  date-only value formatted through a full datetime formatter can shift a
  day near midnight if the formatter applies local timezone to a UTC
  midnight timestamp — parse/format date-only values as calendar dates, not
  instants).

## Persisting the language preference

- Three states to support explicitly: an explicit user choice (English or
  Bokmål) that persists and wins on restart, and "System," which instead
  tracks the device locale live. "System following device changes" means
  subscribing to device locale-change events while the preference is
  System, not just reading the locale once at launch.
- Android specifically fires a locale/configuration change while the app is
  already running (foregrounded) if the user changes system language without
  killing the app — iOS effectively requires a relaunch for a system
  language change to be visible, but you still shouldn't assume that; handle
  the live-update path so Android isn't silently stale.
- A failed preference write must not report success — same durable-write
  discipline as the watchlist in iteration 5, and the plan explicitly flags
  overlap between a language-preference write and a watchlist write, so
  whatever write queue/transaction discipline you built there should extend
  here rather than being a one-off.

## Catalogue language and fallback

- TMDB returns translations per field, and vendor translation data is
  sometimes present but low-quality/misleading (present but wrong, not
  simply absent) — fallback logic needs to treat "field is empty" and "field
  is populated" as the only signal it can safely act on; don't try to guess
  when nonempty vendor text is bad.
- "Preserved result order" while enriching with per-field translations
  implies the enrichment step maps over the existing ordered list in place
  rather than re-fetching/re-sorting.
- Bounded concurrency for enrichment calls (a concurrency limit, e.g. via a
  small semaphore/queue rather than `Promise.all` over an unbounded array) is
  what keeps a page of 20 results from firing 20 simultaneous extra requests
  at TMDB; partial failure of some of those enrichment calls should be
  retryable without re-fetching the ones that already succeeded.

## Refreshing safely across language changes

- This is the same stale-response problem as search cancellation in
  iteration 2 (request tokens / "am I still current"), applied to language
  instead of query text — a language change should invalidate in-flight
  requests for the old language the same way a new search invalidates the
  old one. Reuse that mechanism rather than inventing a parallel one.
- "No mixed-language pagination" means the language a paginated list was
  started in has to be part of that list's identity — a language change
  mid-pagination should trigger a fresh first page in the new language, not
  an appended page in a different language.

## Preserving saved text

- Saved watchlist entries capture the display text _as it was at save time_
  and never re-resolve it against the current interface language —
  practically, that means storing the resolved title/text alongside the
  identity in SQLite, not just the identity plus a "look it up live" join.
  Sorting/collation of that saved list, however, still follows the _current_
  interface language's `Intl.Collator`, which is the distinction the plan is
  drawing between "content language" (frozen) and "interface language"
  (live).

## Theming and accessibility

- Semantic theme tokens (`background`, `foreground`, `border`, etc., mapped
  to actual colors per theme) rather than hardcoded hex values in components
  is what makes "coherent light/dark throughout, including dialogs and
  status bars" tractable — a component that reads `theme.background` gets
  dark mode for free; one with a hardcoded color needs a manual fix per
  occurrence.
- The [React Native accessibility model](https://reactnative.dev/docs/accessibility)
  centers on `accessibilityRole`, `accessibilityLabel`, `accessibilityState`,
  and focus order following render order — TalkBack/VoiceOver read elements
  in the order they appear in the tree, so a visually-reordered layout (e.g.
  via absolute positioning) can produce a confusing reading order even
  though it looks right on screen.
- Test with real device text-scaling (200%) rather than only a design
  review — RN layouts using fixed heights instead of flexible/intrinsic
  sizing are exactly what breaks first under enlarged text, and it's much
  faster to catch this on-device than to infer it from the code.
