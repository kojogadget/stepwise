# Dev loop and navigation (Iteration 1)

## Expo development loop

- The development build vs. Expo Go distinction matters from day one:
  Expo Go is a pre-built sandbox that can only run JS/TS and the native
  modules it ships with. The moment the project needs a native module Expo Go
  doesn't include (SQLite is already on the plan for iteration 5), you need a
  **development build** — a custom-compiled version of the app that behaves
  like Expo Go but includes your actual native dependencies. Get used to
  `npx expo run:ios` / `npx expo run:android` (or EAS dev builds) early
  rather than switching tools later.
- **Fast Refresh** reloads edited components and preserves component state
  where it can infer it; it does _not_ replay native initialization or reset
  module-level state outside React (relevant later for the Jotai store — see
  `state-and-fixtures.md`). If a change to a file with side effects at module
  scope doesn't seem to take effect, that's often why — do a full reload.
- JS-only changes hot-reload; native changes (new native module, changed
  `app.json`/`app.config.ts` native config, new Expo config plugin) require
  rebuilding the development build. Someone new to Expo commonly loses time
  assuming a plain restart is enough after a native-affecting change.
- `npx expo install --check` and `npx expo-doctor` exist because Expo pins
  compatible versions of RN and native deps per SDK version — `npm install`
  alone can silently put you on an incompatible peer version. Run them after
  any dependency change, not just when something breaks.

## Navigation shell (Expo Router)

- Expo Router is file-based: the directory structure under `app/` _is_ the
  route tree. A tab navigator is a directory with a `_layout.tsx` that
  renders `<Tabs>`; a stack is a directory (or the root) with a `_layout.tsx`
  rendering `<Stack>`. Nesting a stack inside a tab (e.g. Search tab has its
  own stack for list → details) is the idiomatic way to get "Back returns to
  the originating tab" — a details screen pushed onto the Search tab's own
  stack, not a shared root stack, naturally returns to Search.
- Routes reachable from multiple tabs (Settings/About here) are usually
  either: a modal presented from each tab's stack, or a shared route group
  outside the tabs that any tab can push onto its own stack. Don't reach for
  a single global stack shared by all tabs — that's what breaks "Back returns
  to the originating tab."
- Safe areas: use `react-native-safe-area-context`'s `useSafeAreaInsets` (or
  `SafeAreaView`) rather than hardcoded padding. Expo Router's navigators
  already account for safe areas around their own chrome (tab bar, header);
  the pitfall is custom content _inside_ a screen (floating buttons, bottom
  sheets) that ignores the inset and ends up under the home indicator or
  status bar.

## Testing router behavior

- Expo Router ships first-class testing support (`expo-router/testing-library`
  building on `@testing-library/react-native`) that lets you render a route
  by path and assert on what's on screen, rather than mocking the navigator.
  Prefer that over hand-rolling navigation mocks — it exercises real route
  resolution, which is exactly what "open details identified by media
  identity" and "Back returns to the correct origin" need to verify.
