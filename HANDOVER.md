# JCF App — Session Handover

> For a fresh session (human or Claude Code) continuing this work with zero prior
> context. **Updated 2026-09-28.** Replaces the June 27 handover, which predated
> the auth, programs and redesign work and is no longer accurate.
>
> Both repos work on branch **`feature/mobile-app`** (renamed from
> `claude/jcf-app-handoff-pgom2q`, which no longer exists on GitHub).

This project spans **two repos**:
- **JCFMobile** (`ebenezerowusu/JCFMobile`): the Flutter app (this repo). It is
  now **mobile-only** (iOS + Android); the desktop app was retired and deleted.
- **JCFAdmin** (`janprince/JCFAdmin`): the Django backend. It is the API layer
  **and** the staff admin dashboard for the app.

Source of truth, in order: the code and git log, then
`docs/DEVELOPMENT_CHECKLIST.md` (the live TODO list), then this file.

---

## 1. Project overview

The **JCF App** is a Flutter app for the **Jan Cosmic Foundation (JCF)**, a
spiritual foundation in Ghana. It brings teachings, daily practice, programs
(retreats) with Paystack payment, donations, announcements and search into one
app, replacing WhatsApp/YouTube/web-form workflows.

**Access model (tiered):**
- **Guests** use the app without signing in and see general content.
- **Members and students** sign in with a one-time code sent to the phone
  number or email on their approved `Contact` record in JCFAdmin. Signing in
  unlocks premium lessons and member/student-only content.
- Home changes by role: guest (design 19), member (20), student (21).

**Timeline:** there is **no hard deadline**. The 2026 retreat ran on the
existing website. The app becomes the registration channel from 2027, so the
goal is to build it properly.

**Designs:** 31 numbered comps live in `design/` (1–18 onboarding and auth,
19–31 the main app). Code comments and commits cite them as "design NN".

## 2. Tech stack & settled decisions (do not relitigate)

### JCFMobile (Flutter)
- **Flutter 3.44.4 / Dart 3.12.2**, Material 3. Locally installed at
  `~/development/flutter` (not on the default shell PATH).
- **Riverpod 3** for state (repository providers + FutureProviders per
  feature), **Dio** for HTTP, **go_router 17** for navigation.
- **flutter_secure_storage** for tokens; **shared_preferences** for small
  local prefs (locale, onboarding seen, notification prefs, recent searches).
- **Hive** is a dependency but **not used yet** (no offline cache).
- **Payments:** Paystack **browser flow**. The backend initializes the
  transaction and returns an `authorization_url`; the app opens it with
  `url_launcher`, then the user taps "I have paid" and the app calls verify.
  No Paystack SDK and no secrets in the app. (The June plan's
  `flutter_paystack_max` is not used.)
- **Media:** no in-app player yet. YouTube/R2 links and practice audio open
  externally; "Mark as done/complete" buttons stand in for playback tracking.
- **l10n:** gen-l10n with ARB files for en, fr, es, de, pt. The app sends
  `Accept-Language`.
- **Monorepo:** `apps/mobile` plus `packages/jcf_ui`, `jcf_models`,
  `jcf_api_client` (path dependencies, `publish_to: 'none'`).

### JCFAdmin (backend / API / admin)
- **Django 6.0.3 + DRF 3.16.1**, Python 3.13, PostgreSQL (Neon; a `dev`
  branch for local work).
- **Cloudflare R2** media via `django-storages` + `boto3`; whitenoise for
  static files.
- **Paystack** in `causes/paystack.py` (`initialize_transaction`,
  `verify_transaction`, `validate_webhook_signature`; uses `requests`).
- **Email:** Gmail SMTP. **SMS:** Arkesel (`website/notifications.py`).
- Deployed on **Railway**. `Procfile` runs gunicorn and applies migrations on
  release.
- A second, unmanaged database (`innerspace` alias) belongs to the
  drbaffourjan.com student platform. See JCFAdmin `CLAUDE.md`; Django never
  migrates it.

### Architecture rules
- **Three tiers only:** Flutter → Django API → Postgres. Flutter never touches
  the database.
- **Mobile API is isolated** under `/api/mobile/v1/` (`mobile_api` app). The
  website API under `/api/` stays untouched.
- **Auth is custom OTP + opaque tokens, not JWT** (simplejwt is not installed):
  - `POST auth/request-code/` → status `sent` / `not_found` / `pending`, plus
    `channel`, `masked_destination`, `retry_after` (and `dev_code` when
    `DEBUG`). Phone identifiers get SMS, with email as fallback. Throttled
    10/min per IP.
  - Codes are 6 digits, stored hashed, valid 10 minutes, 5 attempts.
  - `POST auth/verify-code/` → `access` (7 days) + `refresh` (30 days) +
    `member`. `POST auth/refresh/` issues a new access token (refresh is not
    rotated). `GET auth/me/` returns the profile; `DELETE auth/me/` logs out
    (revokes the token).
  - Requests send `Authorization: Bearer <access>`; `MobileTokenAuthentication`
    sets `request.member` (a `members.Contact`).
- **JCFAdmin is the admin surface** for the app. All staff features (programs
  and fees, content, announcements, inspiration, groups) are built as Django
  dashboard pages, not in Flutter.

## 3. Current state

### Backend (JCFAdmin) — done
About 40 mobile endpoints under `/api/mobile/v1/`, each with a matching
dashboard page:
- **Auth:** request-code, verify-code, refresh, me/logout (`mobile_api`:
  `LoginCode`, `MobileToken`).
- **Teachings:** lessons + series with premium gating by tier; progress and
  Continue Learning (design 26) via `TeachingProgress`.
- **Programs:** `Program`, `AccommodationTier`, `CostLineItem`,
  `Registration`. Dynamic form schema, register → Paystack initialize/verify,
  atomic room allocation, QR code to R2 (`programs/services.py`).
- **Donations:** causes, server-side Paystack init, verify, my donations.
- **Engagement:** announcements with read tracking (design 28), in-app
  notifications, device-token registration, Daily Inspiration (designs 19/22).
- **Practices** (design 27), **activities** feed with reminders (design 25),
  **appointments** (uses `consultations.Consultation`), **groups** with
  approval-gated joins, **global search** + popular searches (designs 30/31).
- **Tests:** 106 Django tests (54 in `mobile_api`). They need a running
  Postgres (`DATABASE_URL`); there is no SQLite test setting.

### Mobile (JCFMobile) — done
- First run: splash, welcome, 3-page onboarding, language picker, path choice,
  stay-connected.
- Auth designs 9–18 complete: sign-in options, phone/email entry, six-box
  verify with resend countdown, resend help, not-found/pending outcomes,
  premium gate, session expired (refresh-on-401 in `AuthInterceptor`), sign-out
  dialog.
- 5-tab shell (Home · Learn · Practice · Programs · More) with role-adaptive
  Home.
- Daily Inspiration detail + share card (PNG), lessons + detail, Continue
  Learning, Practice tab, programs list/detail/register sheet with payment,
  causes + donate sheet, announcements, notifications, appointments,
  activities, search, profile, Quick Actions (More).
- App name "Jan Cosmic Foundation", logo, native splash and launcher icons.
- Android main manifest now declares `INTERNET` (release builds need it).

### Not done
- **Live Now (design 24)**, the last redesign step. Depends on the streaming
  backend (checklist Track 3).
- **8 More-tab tiles go to `ComingSoonScreen`:** Membership Card, My Groups,
  Guidance Request, Find a Centre, My Registrations, Shop, Downloads,
  Settings. Backend already exists for **My Registrations**
  (`registrations/mine/`, provider exists) and **My Groups** (`groups/`).
- **Push notifications:** `engagement/push.py` is a stub (no firebase-admin);
  the app never calls `devices/register/`. Blocked on a Firebase project.
- **Paystack webhook** only records donations, not program registrations
  (registrations confirm only when the app calls verify).
- Practices and activities have no delete in the dashboard.
- No offline cache (Hive unused), no in-app media player.
- Fonts (Cormorant Garamond, Inter) not bundled; `jcf_ui` has only the theme,
  no shared widgets, and many screens use inline `Color(0x…)` literals.
- About 10 screens still have hardcoded English (register/donate sheets,
  causes, programs, program detail, lessons, lesson detail, profile,
  appointments, notifications), against the translation-first rule.
- Tests: one widget test in `apps/mobile/test/widget_test.dart`; no package
  tests.
- No release signing: release builds use the debug key.
- No CI.

## 4. Where we left off

- Latest mobile work: global search (designs 30/31) and the guest Home rebuilt
  on text-free brand assets (`90afdb1`), then the INTERNET permission fix
  (`03da407`).
- Latest backend work: global search API (`ec21be7`).
- A **debug-signed release APK pointed at staging** was built on 2026-09-24 for
  device testing (see §9).
- No file is mid-edit; both working trees are clean.

**Branch state:**
- JCFMobile `feature/mobile-app` is 45 commits ahead of `main` (main is from
  June).
- JCFAdmin `feature/mobile-app` is 25 commits ahead of `origin/main`, and `main`
  has 2 commits it lacks (`8ed872b`, `10eee5f`). Merge or rebase before the
  next PR. `origin/staging` already includes this branch (PR #3).

## 5. Next steps (suggested order)

1. **My Registrations** and **My Groups** screens (backend is live), replacing
   their Coming Soon tiles.
2. Localize the remaining English-only screens.
3. Find a Centre screen (search currently opens an info sheet for centres).
4. Release signing (keystore + `key.properties`), then CI (analyze + test +
   APK artifact).
5. FCM push once a Firebase project exists.
6. In-app media player and offline downloads (checklist Track 1B).
7. Live Now (design 24) with the streaming backend (Track 3).

Keep `docs/DEVELOPMENT_CHECKLIST.md` ticked as items land.

## 6. File map

### JCFMobile (`apps/mobile/lib/`)
- `main.dart`: app root, theme, l10n delegates.
- `app/router.dart`: all routes; `StatefulShellRoute` for the 5 tabs. **No
  route-level redirect** — screens gate themselves (`isLoggedInProvider`,
  premium gate, sign-in prompts). Splash → `/home` if onboarding was seen, else
  `/welcome`.
- `app/shell.dart`: bottom navigation.
- `core/config.dart`: `apiBaseUrl` from `--dart-define=API_BASE_URL`
  (default `http://10.0.2.2:8000/api/mobile/v1/`, the Android emulator's host).
- `core/providers.dart`: `apiClientProvider` (adds Accept-Language), session-
  expired hook that routes to `/session-expired`.
- `core/launch.dart` (external URLs), `core/brand.dart` (logo),
  `core/coming_soon_screen.dart`.
- `features/<domain>/`: `*_repository.dart` + screens for activities, auth,
  donations, engagement, home, inspiration, lessons, more, onboarding,
  practice, profile, programs, search. `home/home_widgets.dart` is the large
  role-adaptive Home.
- `l10n/`: ARB files + generated localizations.

### Packages
- `jcf_api_client`: `JcfApiClient` (Dio, timeouts), `AuthInterceptor`
  (Bearer header, one refresh + retry on 401, then `onSessionExpired`),
  `TokenStore` (secure storage). Endpoints live in the app's repositories.
- `jcf_models`: `Member`, `AuthSession`, `Teaching`, `Paginated<T>`, `Cause`,
  `Program`, `ProgramTier`, `CostLineItem`, `FormField`, `Registration`,
  `Announcement`, `AppNotification`, `Appointment`. (`RetreatConfig` and
  `AccommodationTier` are unused leftovers.) Newer models (inspiration,
  practice, activity, search, continue-learning) sit in the repository files.
- `jcf_ui`: `src/theme.dart` only — `JcfColors`, `JcfRadii`, `JcfTypography`,
  `JcfTheme.light()`.

### JCFAdmin
- `config/urls.py` (dashboard + `/api/` + `/api/mobile/v1/`),
  `config/api_urls.py` (website API + Paystack webhook).
- `mobile_api/`: `urls.py`, views, `authentication.py`, `otp.py`,
  `tests.py`, `test_search.py`.
- Domain apps: `members` (`Contact` = app member identity), `teachings`,
  `programs`, `causes`, `engagement` (incl. `push.py` stub), `groups`,
  `practices`, `activities`, `consultations`, `innerspace`.
- `CLAUDE.md`: dashboard and Innerspace notes (partly outdated on app list).

## 7. Known issues

- **Signature mismatch on install:** debug builds from different machines use
  different debug keys. Installing over a copy signed by another key fails
  (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`); uninstall first (this wipes app
  data).
- The first Gradle build on a machine takes 10+ minutes.
- No production API URL exists in the app; always pass `API_BASE_URL`.
- Django 6 needs Python ≥ 3.12.

## 8. Conventions

- **API hand-in-hand:** build each feature's JCFAdmin API, dashboard page and
  Django tests in the same pass as its Flutter screen, and test end to end
  against the real endpoint.
- **Translation-first:** every new screen ships with ARB strings for all
  Wave-1 languages; direction-aware widgets only; server text honours
  `Accept-Language`.
- **Nothing hardcoded:** fees, dates, tiers and copy come from the API or l10n.
- **Secrets server-only:** Paystack secret, R2 keys and signing keys never go
  in Flutter. The public Paystack key is served by `payments/config/`.
- **Payments idempotent:** unique references; webhook work in one transaction.
  Registration reference format `JCF-{YEAR}-{5-digit id}`, e.g.
  `JCF-2026-00142`.
- **Guest-gated surfaces** always fall back to a sign-in invitation.
- **Dart:** PascalCase classes, snake_case files, `library;` barrels.
- **Django:** new domains as separate apps with migrations; run migrations on
  the Neon `dev` branch before production.
- **Git:** work on `feature/mobile-app` in both repos. Don't open PRs unless
  asked. Keep `flutter analyze` + `flutter test` green.

## 9. How to run

### Backend (JCFAdmin)
```bash
python3.13 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env        # fill values; .env is gitignored
python manage.py migrate
python manage.py runserver  # admin dashboard + /api/ + /api/mobile/v1/
python manage.py test       # needs Postgres
```
Key env vars: `SECRET_KEY`, `DATABASE_URL`, `INNERSPACE_DATABASE_URL`,
`CLOUDFLARE_R2_*`, `EMAIL_HOST_USER/PASSWORD`, `ARKESEL_API_KEY`,
`PAYSTACK_SECRET_KEY`, `PAYSTACK_PUBLIC_KEY`, `CORS_ALLOWED_ORIGINS`.
With `DEBUG=True`, request-code returns `dev_code` so you can sign in without
SMS/email.

### Flutter app (JCFMobile)
```bash
export PATH=$HOME/development/flutter/bin:$PATH
cd apps/mobile && flutter pub get
flutter analyze && flutter test

# Local backend (Android emulator; use http://localhost:8000 for iOS sim)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/mobile/v1/

# Staging backend, on a connected device
flutter run -d <device-id> \
  --dart-define=API_BASE_URL=https://jcfadmin-staging.up.railway.app/api/mobile/v1/

# Staging APK for testers (debug-signed until release signing exists)
flutter build apk --release \
  --dart-define=API_BASE_URL=https://jcfadmin-staging.up.railway.app/api/mobile/v1/
# → build/app/outputs/flutter-apk/app-release.apk (~66 MB; add --split-per-abi for smaller files)
```

## 10. Open questions (for the project owner)

- **Release accounts:** who owns the Firebase project, Apple Developer and
  Google Play accounts? Blocks push notifications and store release.
- **Release signing:** where the Android upload keystore will live and who
  holds it.
- Owner decisions listed in the checklist and `JCF_App_Feature_Specification.pdf`:
  roadmap priority, premium model, streaming/meeting platform (blocks Live
  Now), shop delivery scope, translation sourcing.
- Transactional email at scale: stay on Gmail SMTP or move to a provider.
