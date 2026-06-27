# JCF App — Session Handover

> For a fresh Claude Code session continuing this work with zero prior context.
> Written 2026-06-27. Both repos are on branch `claude/jcf-app-handoff-pgom2q`
> with **clean working trees — everything is committed and pushed**.

This project spans **two repos**:
- **JCFMobile** (`ebenezerowusu/JCFMobile`) — the Flutter app monorepo (this repo).
- **JCFAdmin** (`janprince/JCFAdmin`) — the existing Django backend that IS the API layer.

---

## 1. Project overview

The **JCF App** is a cross-platform Flutter application (iOS + Android mobile, and a
Windows/macOS/Linux admin desktop app) for the **Jan Cosmic Foundation (JCF)**, a
spiritual foundation in Ghana. It unifies retreat registration + Paystack payment,
member management, teachings/content, donations, and engagement into one platform,
replacing fragmented WhatsApp/YouTube/web-form workflows. The hard near-term goal is
having **retreat registration with Paystack payment live before the 2026 retreat on
July 31**.

## 2. Tech stack & key decisions (settled — do not relitigate)

### JCFMobile (Flutter)
- **Flutter 3.44.4 / Dart 3.12.2**, Material 3 — single codebase for mobile + desktop.
- **Riverpod** (`flutter_riverpod`) for state — compile-safe, testable, `AsyncNotifier`.
- **Dio** for HTTP — interceptors for JWT header injection + logging.
- **Hive** for offline cache (retreat config 1h TTL, form state, downloads).
- **flutter_secure_storage** for JWT tokens (iOS Keychain / Android Keystore).
- **go_router** for navigation.
- **flutter_paystack_max** for payments — NOTE: handoff doc named `flutter_paystack`,
  but that package is unmaintained / not null-safe, so we substituted the maintained
  `flutter_paystack_max` (card + MTN MoMo). Swap freely if you prefer another fork.
- **Monorepo layout** (`apps/*`, `packages/*`) — shared design system, models, API client.

### JCFAdmin (backend / API layer) — already exists, mature
- **Django 6.0.3 + Django REST Framework 3.16.1** on **PostgreSQL** (Render/Railway).
  Requires **Python ≥ 3.12** (Django 6). Verified locally on 3.13.
- **Cloudflare R2** media storage via `django-storages` + `boto3` (S3-compatible).
- **Paystack** payments — `causes/paystack.py` (verify + HMAC-SHA512 webhook).
- **Email** Gmail SMTP; **SMS** Arkesel (`website/notifications.py`).
- Custom user model `accounts.User` (email login), DRF default permission `AllowAny`.

### CRITICAL architectural finding (corrects the original handoff doc)
The original planning doc (`JCF_App_Product_Documentation.docx`) assumed a *separate,
TBD API repo* and a *new Neon Postgres project*. **That is wrong / outdated.** In
reality **JCFAdmin is the backend** and already implements ~60% of what the doc lists
as "not started": Postgres, DRF API, Paystack, R2, email, SMS are all live. So:
- Mobile APIs are **added to JCFAdmin**, not a new repo.
- DB changes are **Django migrations**, NOT raw Neon SQL / dbmate.
- Flutter → Django (HTTP) → Postgres. Flutter NEVER touches Postgres directly.
  Secrets (Paystack secret, R2, JWT private key) live only on the server, never in Flutter.

## 3. Current state

### Done & working
- **JCFMobile monorepo scaffolded** with real `flutter create`. `flutter analyze` clean
  and `flutter test` passing for BOTH `apps/mobile` and `apps/desktop`.
- `packages/jcf_ui` — JCF design tokens + Material 3 theme (`src/theme.dart`).
- `packages/jcf_api_client` — Dio client + JWT `AuthInterceptor` + secure `TokenStore`.
- `packages/jcf_models` — `RetreatConfig`, `AccommodationTier` models.
- Both app shells wired with `ProviderScope` + `MaterialApp.router` + `JcfTheme.light()`.
- `.claude/hooks/session-start.sh` + `.claude/settings.json` — SessionStart hook that
  auto-installs Flutter on web sessions (async mode, idempotent).
- `docs/DEVELOPMENT_CHECKLIST.md` — full follow-along checklist (Track A / Track B).
- **JCFAdmin** verified runnable locally: venv (py3.13), `migrate`, `check`, and the
  API serves (`GET /api/events/` → 200). `.env.example` committed.

### Partially done
- Shared packages are skeletons — need more models, real typed endpoints, widgets.
- `jcf_api_client` has no refresh-on-401 yet; `baseUrl` not yet wired to a config flag.
- Hive added to deps but not initialized/used.
- Routing is a single placeholder route per app (no auth-gated shell, no real screens).

### Not started
- Retreat domain in JCFAdmin (models, migrations, seed, mobile API namespace).
- Mobile auth (JWT) — no token auth exists in JCFAdmin at all today.
- All real Flutter feature screens (registration, teachings, etc.).
- Firebase/FCM, CI/CD, fonts bundling, store packaging.

## 4. Where we left off

The last work was **session-handover + local verification**; there is **no mid-edit
file** — both repos have clean trees, all committed and pushed.

The agreed **next concrete step is Track A1: build the retreat domain in JCFAdmin** —
a new `retreats` Django app with models `RetreatConfig`, `AccommodationTier`,
`CostLineItem`, `RetreatRegistration`, plus migrations and a 2026 seed. This is BLOCKED
only by user decisions D1–D4 (see §10). The user leans toward the deadline-safe path
(Django-hosted registration page + guest registration) but had not finally confirmed.

The user also asked about local/device workflow: this session runs in an ephemeral
cloud container with NO access to the user's machine. To get a direct edit-and-run loop
on their device they would run Claude Code locally; otherwise the flow is: edit + verify
here → push to the feature branch → user pulls and tests on a device → merge to main.

## 5. File map

### JCFMobile (this repo)
- `apps/mobile/` — iOS+Android app (`jcf_mobile`). Entry: `lib/main.dart` (`JcfApp`,
  `HomeScreen`, go_router `_router`). Test: `test/widget_test.dart`.
- `apps/desktop/` — Windows/macOS/Linux admin app (`jcf_desktop`). Entry: `lib/main.dart`
  (`JcfDesktopApp`, `AdminHomeScreen`). Test: `test/widget_test.dart`.
- `packages/jcf_ui/lib/src/theme.dart` — `JcfColors`, `JcfRadii`, `JcfTypography`,
  `JcfTheme.light()`. Barrel: `lib/jcf_ui.dart`.
- `packages/jcf_models/lib/src/retreat_config.dart` — `RetreatConfig` (+ `fromJson`).
- `packages/jcf_models/lib/src/accommodation_tier.dart` — `AccommodationTier`
  (`isSoldOut`, `roomsAvailable`). Barrel: `lib/jcf_models.dart`.
- `packages/jcf_api_client/lib/src/jcf_api_client_base.dart` — `JcfApiClient` (Dio,
  baseUrl, timeouts).
- `packages/jcf_api_client/lib/src/auth_interceptor.dart` — `AuthInterceptor` (Bearer).
- `packages/jcf_api_client/lib/src/token_store.dart` — `TokenStore` (secure storage).
- `.claude/hooks/session-start.sh` — installs Flutter on web sessions; `.claude/settings.json` registers it.
- `docs/DEVELOPMENT_CHECKLIST.md` — the live TODO checklist.
- `HANDOVER.md` — this file.

### JCFAdmin (backend, separate repo at /home/user/JCFAdmin)
- `config/settings.py` — DRF, CORS, R2 storage, Paystack, email/SMS config (all via env).
- `config/urls.py` — routes; `path('api/', include('config.api_urls'))`.
- `config/api_urls.py` — ALL existing API views + URL patterns (events, blog, centres,
  causes, gallery/team/testimonials, form submissions, `donations/verify/`,
  `webhook/paystack/`). **This is where the mobile API namespace gets added.**
- `causes/paystack.py` — `verify_transaction()`, `validate_webhook_signature()` (reuse).
- `causes/models.py` — `Cause`, `Donation` (Paystack idempotent on `paystack_reference`).
- `members/models.py` — `Contact` (core person record), `DataFile`, `Inquiry`.
- `accounts/models.py` — `User` (email login), `Profile` (roles).
- `consultations/models.py` — `Consultation` (can extend for appointments).
- `website/notifications.py` — `send_sms_arkesel()`, email helpers (reuse for confirmations).
- `.env.example` — full env var template (no secret values).

## 6. Next steps (prioritized)

1. **Get D1–D4 answered** (§10) — they gate Track A.
2. **Track A1 — retreat domain in JCFAdmin:** new `retreats` app; models
   `RetreatConfig`, `AccommodationTier`, `CostLineItem`, `RetreatRegistration`;
   `makemigrations` + `migrate`; register in Django admin; seed 2026 config + tiers.
3. **Track A2 — mobile API + payment:** add `path('api/mobile/v1/', include('mobile_api.urls'))`;
   `GET retreat/active`; `POST registrations/initiate` (ref `JCF-2026-#####`); extend the
   Paystack webhook to handle registration charges (atomic txn, idempotent, atomic room
   allocation `UPDATE ... WHERE rooms_confirmed < total_rooms`); send email/SMS + QR→R2.
4. **Track A3 — registration surface** (Django page or Next.js per D1) for July 31.
5. **Track A4 — test with Paystack test keys → switch to live → go live.**
6. **Track B** (after/parallel): JWT auth, Flutter retreat flow (`RetreatConfigProvider`
   + Hive 1h cache, 4-step form, cost summary, Paystack popup, confirmation/QR),
   teachings, engagement/FCM, journey/service, packaging/CI/store release.
- Full breakdown lives in `docs/DEVELOPMENT_CHECKLIST.md` — keep it ticked as you go.

## 7. Known issues & blockers

- **Python version:** Django 6 needs Python ≥ 3.12. The container's default `python3` is
  3.11 (too old); use `python3.13`. Verified working with a 3.13 venv.
- **No Postgres server** in the cloud container (only the `psql` client) — local backend
  verification used SQLite (`DATABASE_URL=sqlite:///db.sqlite3`). Use real Postgres on a
  dev machine / production.
- **No mobile auth yet:** DRF default is `AllowAny`; no JWT/token auth installed. Members
  are `Contact` records, not auth users — the Contact↔app-user link must be designed.
- **Flutter runs as root** in the cloud container (harmless warning). Cannot produce
  signed iOS/Android builds here (no Xcode/Android SDK); analyze + test are the ceiling.
- **Ephemeral container:** the Flutter SDK, `.venv`, `.env`, and `db.sqlite3` created here
  do NOT persist. Only committed+pushed files survive. The SessionStart hook re-installs
  Flutter next time.
- Paystack package substitution (`flutter_paystack_max`, see §2) — intentional deviation.

## 8. Conventions

- **Three-tier always:** Flutter → Django API → Postgres. Never Flutter → DB directly.
- **Dynamic config, never hardcoded:** all fees/dates/tiers come from the API at runtime.
  Zero hardcoded numbers in Flutter.
- **Secrets server-only:** Paystack secret, R2 keys, JWT private key never in Flutter.
  Public Paystack key is served via the retreat config (rotatable without a release).
- **Mobile API isolation:** add a NEW `/api/mobile/v1/` namespace; leave the existing
  website `/api/` untouched.
- **Dart:** PascalCase classes (`RetreatConfig`), snake_case files (`retreat_config.dart`);
  packages use `library;` barrels and `publish_to: 'none'`; path deps between packages.
- **Django:** snake_case plural tables; reuse `causes/paystack.py` and
  `website/notifications.py`; new domains as separate apps with migrations.
- **Paystack reference format:** `JCF-{YEAR}-{5-digit-zero-padded-id}` e.g. `JCF-2026-00142`.
- **Payments idempotent** via unique reference / `get_or_create`; webhook in one transaction.
- **Git:** work on `claude/jcf-app-handoff-pgom2q` in BOTH repos; `git push -u origin`
  with retry/backoff on network errors. Do NOT open PRs unless the user asks.

## 9. How to run

### Backend (JCFAdmin, at /home/user/JCFAdmin or your clone)
```bash
python3.12 -m venv .venv && source .venv/bin/activate   # Python 3.12+ REQUIRED
pip install -r requirements.txt          # (uv pip install -r requirements.txt is faster)
cp .env.example .env                      # then fill values; .env is gitignored
#   quick local DB:  DATABASE_URL=sqlite:///db.sqlite3
#   production-like:  DATABASE_URL=postgres://USER:PASS@localhost:5432/jcf_management
python manage.py migrate
python manage.py createsuperuser
python manage.py check
python manage.py runserver               # http://127.0.0.1:8000  (API /api/, admin /admin/)
```
- Config/secrets: `.env` (local, gitignored) and host env vars (prod). Template:
  `.env.example`. Keys: `SECRET_KEY`, `DATABASE_URL`, `CLOUDFLARE_R2_*`,
  `EMAIL_HOST_USER/PASSWORD`, `ARKESEL_API_KEY`, `PAYSTACK_SECRET_KEY`,
  `CORS_ALLOWED_ORIGINS`. **Never commit values.**

### Flutter app (JCFMobile)
```bash
# Flutter stable 3.44+ (Dart 3.12). On Claude web sessions the SessionStart hook
# installs it automatically; locally install Flutter yourself.
cd apps/mobile && flutter pub get        # repeat per app/package as needed
flutter analyze
flutter test
flutter run -d <android|ios|macos|windows|linux|chrome>
```
- Emulator → local backend: Android `http://10.0.2.2:8000`, iOS/desktop `http://localhost:8000`.

## 10. Open questions (awaiting user input)

- **D1 (blocks A3):** July-31 registration page on **JCFAdmin (Django template)** or on the
  existing **Next.js website**? (Recommended: Django, for speed.)
- **D2 (blocks A/critical path):** **Guest registration** (name/email/phone, no account —
  faster, recommended) or **full JWT login** before July 31?
- **D3 (blocks A1 seed):** Confirm 2026 values — adult GHS 400, child GHS 200, venue Windy
  Lodge / Aquambias, dates Jul 31–Aug 9, and the full accommodation tier list (names,
  price/person, room counts). The tier list is referenced but not enumerated.
- **D4 (blocks A4 go-live):** Is the JCF Paystack live business account active, and are
  both test + live secret/public keys available?
- **D5 (blocks Track B only):** Owners of Firebase, Apple Developer ($99/yr), Google Play
  ($25) accounts — for push notifications and store launch.
- Email provider for transactional mail at scale (currently Gmail SMTP) — confirm or change.
