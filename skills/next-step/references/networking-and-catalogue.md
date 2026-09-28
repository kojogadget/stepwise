# Networking and catalogue data (Iterations 3–4)

## HTTP boundary and configuration

- The idiomatic shape is a thin adapter layer that owns the TMDB HTTP client
  (base URL, auth header, timeout, retry policy) behind the same kind of
  repository interface used for the sample data in iteration 1 — the
  ViewModel/domain code should not know it's talking to TMDB specifically.
- "Configuration validation" means failing fast and explicitly (a typed
  configuration-error result) if the API key/bearer token is missing or
  malformed at startup, rather than letting every request fail individually
  with a generic network error later.
- Auth only on catalogue requests, never image requests (a `CLAUDE.md`
  invariant): this is usually a signal that the image loader/adapter must be
  a genuinely separate client from the catalogue client, not the same
  `fetch` wrapper with a flag — separating them at the type level makes it
  structurally impossible to attach the bearer token to an image request.
- Model timeout, cancellation, service failure, and rate limiting as distinct
  members of a discriminated union result type (not thrown exceptions caught
  ad hoc) — that's what lets presentation show a different message per
  failure kind, and what the "documented retry rule" almost certainly hangs
  off of (e.g. only retry on timeout/5xx, never on 4xx or rate limiting
  without backoff).

## Mapping external data safely

- DTOs (Data Transfer Objects) are the raw shape TMDB's JSON actually has;
  domain values are what the rest of the app trusts. The mapping step between
  them is where you validate — a schema validation library (e.g. Zod) run on
  the raw response before mapping is the idiomatic way to guarantee "malformed
  responses must not become false 'no matches'": a validation failure should
  surface as a distinct error state, not silently produce an empty result
  list that looks identical to a genuine empty search.
- Filtering people/adult/invalid entries out of a TMDB response belongs in
  the mapping layer, applied per-item, so one bad item doesn't invalidate an
  otherwise-good page — "pages containing only excluded results" then just
  falls out as an empty-but-valid mapped page, which the ViewModel treats
  like any other empty page (not an error).
- Duplicates across a single response (TMDB does return them) get deduped
  the same way as pagination duplicates — by the kind+id identity value, not
  positionally.

## Images

- TMDB doesn't return full image URLs; it returns a path, and you combine it
  with a base URL + size from the `/configuration` endpoint (or a
  reasonably-current hardcoded base if you choose not to fetch it live —
  either way, treat "unavailable image configuration" as its own failure
  case, not a crash).
- Poster loading failure should degrade to a placeholder without blocking or
  delaying the surrounding text/actions — i.e. image load state is local to
  the image component, not something the card/detail screen waits on before
  rendering anything else.
- A basic cache policy (RN's `Image`/`expo-image` disk caching, or explicit
  memory+disk caching if you roll your own) avoids re-fetching the same
  poster on every scroll-back; `expo-image` is the more modern, idiomatic
  choice over the core `Image` component for this if it's already a
  dependency, since it caches more aggressively by default.

## Details, routing, and lifecycles

- Route params in Expo Router are just URL-like segments/query params —
  keep them to the identity (kind + id) and nothing else; re-fetch full
  detail from the repository by that identity rather than passing a whole
  result object through navigation. That's both what "open details without
  retaining a result object" is testing for, and what makes deep-linking to
  a details screen work for free.
- Route validation: treat unknown kind, non-numeric id, or missing params the
  same way you treat a repository-level "not found" — as a typed failure
  state the details screen can render (with a way back), not a thrown error
  that crashes the screen.
- Aggregate credits: TMDB's aggregate-credits endpoint for TV returns roles
  per-episode-count rather than one flat cast list; "first ten in catalogue
  order, including TV character roles" means sorting/slicing that response
  by TMDB's own order rather than re-sorting by name or popularity yourself.
- Screen lifecycle / independent instances: Expo Router gives each pushed
  route its own component instance and lifecycle by default, but a
  ViewModel you construct once in composition and pass down does _not_
  automatically get a fresh instance per navigation — if two details screens
  need independent state, the ViewModel construction has to happen per-route
  (e.g. keyed by the route's params), and any in-flight async work from a
  disposed screen must check "am I still mounted/current" before applying
  its result (the same request-token idea used for search cancellation).
