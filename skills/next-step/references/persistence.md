# Local persistence (Iterations 5–6)

## SQLite via expo-sqlite

- `expo-sqlite` is a real native SQLite binding, not a mock or a web shim —
  which is exactly why iteration 6 insists on testing with real native
  builds around commit boundaries rather than trusting a mocked database in
  unit tests alone. Unit tests with a temporary/in-memory database are fine
  for logic; they can't tell you whether a commit actually survives an app
  kill.
- Schema versions: use `PRAGMA user_version` (or an explicit migrations
  table) to track schema version and run migrations forward on open. "Usable
  storage, genuinely new storage, unreadable/unsupported data" are three
  distinct startup outcomes to model explicitly — don't collapse "no
  database file yet" and "database file exists but is corrupt" into the same
  code path, since one is a normal first launch and the other must preserve
  the unreadable data rather than overwrite it.
- Blocking writes when storage isn't ready ("confirm writes are blocked when
  storage cannot safely accept them") means the storage-readiness state has
  to be checked by whatever queues/executes writes, not just by the UI that
  happens to disable a button — a background write path also needs the
  guard.

## Transactions and durable success

- "Report save/remove success only after the storage transaction commits" —
  the idiomatic shape is: the write function wraps the SQLite statement(s) in
  an explicit transaction, and the promise/result it returns only resolves
  successfully after that transaction's commit succeeds. A pending/optimistic
  UI state (showing "saving…" immediately) is fine and expected for
  responsiveness, but it's a distinct state from "committed," and a failure
  after the optimistic update must roll the UI back to the pre-existing
  (durable) state rather than leaving it in a state that was never actually
  saved.
- "Repeated adds preserve the saved snapshot and date" means insert should be
  an upsert-that-no-ops on conflict (or an explicit existence check before
  insert) rather than a blind `INSERT` that would either error or silently
  reset the saved date on a duplicate add.
- Confirmation flows for destructive actions (remove) pair naturally with a
  controlled/injectable clock for the date-stamping behavior — inject a
  clock function rather than calling `Date.now()` directly, so tests can
  assert "removing and re-adding produces a new date" deterministically.

## Sorting, filtering, and offline restart

- Persisted snapshots: the watchlist's sort/filter/scroll state surviving
  navigation is a session-level concern (in-memory, e.g. a Jotai atom), while
  the watchlist _contents_ surviving app restart is a storage-level concern
  (SQLite) — don't conflate the two; only the contents need to be durable
  across a real process restart.
- Locale-aware sorting for titles should use `Intl.Collator` (with the
  active locale) rather than a plain string `<`/`localeCompare` default
  call, since Bokmål collation order differs from a naive byte/codepoint
  sort. This becomes directly relevant again in iteration 7.

## Testing native persistence and recovery

- WAL (write-ahead logging) mode is what `expo-sqlite` typically uses by
  default; understanding it matters because it changes what "partial write"
  even means — WAL is designed so a crash mid-transaction leaves the main
  database file consistent as of the last commit, with uncommitted changes
  living only in the WAL file. Crash-consistency tests should kill the
  process at a point _before_ a commit and verify nothing partial landed,
  then kill it _after_ and verify the committed data is intact.
- Migration rollback / newer-format handling: a build should refuse to
  silently "upgrade" data written by a newer schema version than it knows
  about, and should have a defined, tested behavior for "this database is
  from a future version I don't understand" rather than treating it as
  ordinary corruption.
- Fault injection for concurrency (6.1) means deliberately controlling which
  of several in-flight operations (add/remove/retry) resolves or fails
  first in a test, to prove an earlier failure can't undo a later success —
  this is easiest with an injectable/fake storage layer whose responses you
  can sequence explicitly, rather than trying to race real SQLite timing.
