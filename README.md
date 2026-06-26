# JCF App

Cross-platform Flutter monorepo for the **Jan Cosmic Foundation (JCF)** — mobile
(iOS + Android) and an admin desktop app (Windows + macOS + Linux), sharing one
Dart codebase, design system, and API client.

The backend / API layer is the Django app **JCFAdmin** (DRF + PostgreSQL +
Paystack). Flutter clients talk to it over HTTP and never connect to the
database directly.

## Structure

```
apps/
  mobile/            # iOS + Android app (jcf_mobile)
  desktop/           # Windows/macOS/Linux admin app (jcf_desktop)
packages/
  jcf_ui/            # Shared design system — JCF colours, radii, typography, theme
  jcf_models/        # Shared Dart models (RetreatConfig, AccommodationTier, …)
  jcf_api_client/    # Dio HTTP client + JWT auth interceptor + secure token store
.claude/
  hooks/             # SessionStart hook that installs Flutter on web sessions
```

## Tech

- **Flutter 3.44 / Dart 3.12**, Material 3
- **Riverpod** (state), **Dio** (HTTP), **Hive** (offline cache),
  **flutter_secure_storage** (JWT), **go_router** (navigation),
  **flutter_paystack_max** (payments)

## Develop

```bash
# Each app/package resolves its own deps
cd apps/mobile && flutter pub get

flutter run -d ios          # or android / macos / windows / linux
flutter analyze
flutter test
```

> The Flutter SDK is installed automatically in Claude Code on the web via
> `.claude/hooks/session-start.sh`. Locally, install Flutter stable yourself.

## Design system

Tokens are pixel-sampled from jancosmicfoundation.org and live in
`packages/jcf_ui/lib/src/theme.dart` (hero navy `#141667`, gold `#D4A843`,
cream `#F2EFE9`; Cormorant Garamond headings, Inter body).
