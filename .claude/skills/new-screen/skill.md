---
name: new-screen
description: Scaffold a new screen following project conventions
---

When creating a new screen, follow the existing pattern:

1. **Screen** (`lib/screens/<feature>/`): Create `<name>_screen.dart` with a `ConsumerStatefulWidget` or `ConsumerWidget`. Use `ref.watch()` for reactive state, `ref.read()` for one-time actions.

2. **Provider** (`lib/providers/`): If the screen needs its own state, add a provider file. Use `FutureProvider` for async data, `NotifierProvider` for mutable state.

3. **Repository** (`lib/services/`): If the screen calls new API endpoints, add methods to the relevant repository or create a new one following the existing pattern (extends HTTP client with Firebase token auth).

4. **Models** (`lib/models/`): Add request DTOs in `requests/` and response DTOs in `responses/` as needed.

5. **Route** (`lib/router/app_router.dart`): Add a `GoRoute` entry. If it's a main tab, add under the `ShellRoute`. If it's a standalone page, add at the top level.

6. **i18n**: Add translation keys to the relevant `lib/i18n/<domain>_en.i18n.json` and `lib/i18n/<domain>_vi.i18n.json`, then run `/slang`.
