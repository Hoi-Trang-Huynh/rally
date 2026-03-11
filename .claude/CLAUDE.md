# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Quick Reference

- `flutter run` / `flutter build apk` / `flutter test` / `flutter test --coverage`
- `/slang` — regenerate i18n translations
- `/new-screen` — scaffold a new screen following project conventions

## Architecture

Flutter app with **Riverpod** state management and **GoRouter** navigation.

- **Structure**: feature-first under `lib/screens/`, shared layers for models, services, providers
- **State**: Riverpod 2.6.1 — `Provider`, `FutureProvider`, `StreamProvider`, `NotifierProvider` with `AsyncValue` pattern
- **Routing**: GoRouter with `ShellRoute` for bottom nav; auth redirects driven by `authChangeNotifier`
- **Backend**: HTTP client (`lib/services/api_client.dart`) with Firebase token auth against rally-backend API

## Key Layers

- **Models** (`lib/models/`): data classes + `requests/` DTOs + `responses/` DTOs. Enums in `enums.dart`
- **Services** (`lib/services/`): repositories for API calls (`rally_repository`, `user_repository`, `auth_repository`, `cloudinary_repository`, `feedback_repository`) + `shared_prefs_service`
- **Providers** (`lib/providers/`): Riverpod providers — one file per domain (auth, user, rally, theme, locale, nav, etc.)
- **Screens** (`lib/screens/`): feature folders (auth, home, chat, discovery, rally, profile, invite, onboarding, playground)
- **Themes** (`lib/themes/`): design system — colors, spacing, text styles, light/dark theme definitions
- **Widgets** (`lib/widgets/`): shared reusable components
- **Utils** (`lib/utils/`): helpers for validation, error handling, dates, images, responsive layout

## Coding Style & Conventions

### Imports
- **Absolute imports only** — `package:rally/...`, never relative `../`
- Order: dart → flutter → third-party packages → app imports
- No barrel files — import each file directly

### Naming
- Files: `snake_case.dart` (e.g. `home_screen.dart`, `user_repository.dart`)
- Classes: `PascalCase` with suffix — `HomeScreen`, `UserRepository`, `ProfileResponse`
- Variables/params: `camelCase`. Private fields: `_camelCase`
- Build helpers: `_build<Section>()` (e.g. `_buildTemplateCard()`)

### Theming & Styling
- **Always use the design system** — never hardcode colors, spacing, or text styles
- Colors: `Theme.of(context).colorScheme.surface`, `colorScheme.primary`, etc. Use `AppColors` constants only for brand-specific values
- Spacing: `Responsive.w(context, 16)` / `Responsive.h(context, 16)` or `AppSpacing.md(context)` — never raw `SizedBox(height: 16)`
- Text: `Theme.of(context).textTheme.titleLarge?.copyWith(...)` — never direct `TextStyle()`
- Common locals at top of build: `final colorScheme = Theme.of(context).colorScheme;` `final textTheme = Theme.of(context).textTheme;`

### Riverpod Patterns
- `ref.watch()` in build methods (reactive), `ref.read()` for one-time actions (callbacks, initState)
- `AsyncValue.when(data:, loading:, error:)` for async state — use `ShimmerLoading()` for loading, `ErrorState()` for errors
- `ref.invalidate(provider)` after mutations to refresh data
- `FutureProvider.autoDispose.family` for parameterized auto-cleaned providers
- `NotifierProvider` for mutable state with persistence (theme, locale)

### Common Widgets (use these, don't rebuild)
- `EmptyState(icon:, title:, subtitle:, actionLabel:, onAction:)` — empty list states
- `ErrorState(error:, onRetry:, retryLabel:)` — error displays
- `ShimmerLoading()` — loading skeletons
- `ScaleButton` — button with scale animation
- `GlassContainer` — frosted glass effect
- `CollapsibleSection` — expandable sections
- `RichTextEditor` / `RallyRichTextViewer` — rich text editing/viewing
- `StackedAvatars` — overlapping avatar row
- `AppBottomSheet` — standardized bottom sheets
- `SliverAppHeader` — sliver-based app bar
- `RallyShell` / `SecondaryShell` — screen wrappers

### Screen Structure
- Use `ConsumerStatefulWidget` / `ConsumerWidget` (not plain StatefulWidget)
- Large screens: `CustomScrollView` with slivers
- Complex sections: extract to private `_build*()` methods in the State class
- No separate widget files per screen — extract to `lib/widgets/` only if reusable across screens

### Forms
- `TextEditingController` + manual `String?` error fields (not `GlobalKey<FormState>`)
- Validate with `Validators.validateX()` returning `null` (valid) or error string
- Loading state: `bool _isLoading` toggled with `setState`
- After mutation: `ref.invalidate()` to refresh, show `showErrorSnackBar()` on failure

### Navigation
- `context.go('/path')` to navigate (replace), `context.push('/path')` to push
- Route constants in `AppRoutes` class — e.g. `AppRoutes.home`, `AppRoutes.userProfile(userId)`
- Path params via `state.pathParameters['key']`

### Error Handling
- API errors: `ApiException(statusCode, message)` thrown by `ApiClient`
- Display: `showErrorSnackBar(context, message)` or `ErrorState` widget
- Always check `if (mounted)` before `setState` in async callbacks

### Other
- Strict linting: `strict-casts`, `strict-inference`, `strict-raw-types`
- i18n: Slang (EN + VI) — translations in `lib/i18n/`, access via `t.section.key`
- Never edit files in `lib/i18n/generated/` — run `/slang` to regenerate
- CI/CD: Codemagic on push to `master`
- Environment: `.env` with `API_BACKEND_URL`, loaded via `flutter_dotenv`
