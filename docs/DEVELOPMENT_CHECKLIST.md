# JCF App — Development Checklist

A follow-along checklist for building the JCF App (Flutter mobile + desktop)
on top of the **JCFAdmin** Django backend.

- **Today:** 2026-06-26 · **Hard deadline:** Retreat registration live by **2026-07-31**
- Repos: `ebenezerowusu/JCFMobile` (Flutter) · `janprince/JCFAdmin` (backend/API)
- Tick `[x]` as you complete each item. Order matters — Track A is the deadline path.

---

## ✅ Phase 0 — Foundations (DONE)

- [x] Backend confirmed = JCFAdmin (Django 6 + DRF) — no separate API repo needed
- [x] PostgreSQL database live (Render/Railway)
- [x] Cloudflare R2 media storage wired (`django-storages` + `boto3`)
- [x] Email (Gmail SMTP) + SMS (Arkesel) helpers in place
- [x] Paystack verify + webhook (donations) implemented
- [x] Public website API live (`/api/…`)
- [x] Flutter monorepo scaffolded (apps/mobile, apps/desktop, packages × 3)
- [x] Shared design system (`jcf_ui` theme tokens)
- [x] `jcf_api_client` (Dio + JWT interceptor + secure token store) skeleton
- [x] `jcf_models` skeleton (RetreatConfig, AccommodationTier)
- [x] SessionStart hook auto-installs Flutter on web sessions
- [x] `flutter analyze` + `flutter test` green; pushed

---

## 🔴 DECISIONS TO MAKE FIRST (blockers)

- [ ] **D1.** July-31 registration surface: Django page on JCFAdmin **/** page on existing Next.js site
- [ ] **D2.** Auth for July 31: **guest registration** (faster) **/** full JWT login now
- [ ] **D3.** Confirm 2026 seed values: adult GHS 400, child GHS 200, venue Windy Lodge, dates Jul 31–Aug 9, accommodation tiers
- [ ] **D4.** Paystack: live business account + live/test API keys available?
- [ ] **D5.** Firebase + Apple Developer + Google Play accounts — who owns them?

---

## 🟥 TRACK A — Retreat registration LIVE by July 31 (CRITICAL PATH)

### A1. Retreat domain in JCFAdmin
- [ ] Create `retreats` Django app
- [ ] Models: `RetreatConfig`, `AccommodationTier`, `CostLineItem`, `RetreatRegistration`
- [ ] `makemigrations` + `migrate`
- [ ] Register models in Django admin (so staff can edit fees/tiers)
- [ ] Seed 2026 `RetreatConfig` + accommodation tiers (per D3)

### A2. Registration + payment API
- [ ] New mobile API namespace: `path('api/mobile/v1/', include('mobile_api.urls'))`
- [ ] `GET /api/mobile/v1/retreat/active` → config + tiers (+ public Paystack key)
- [ ] `POST /api/mobile/v1/registrations/initiate` → pending registration + Paystack ref `JCF-2026-#####`
- [ ] Extend Paystack webhook to handle **registration** charges (not just donations)
- [ ] Atomic transaction + idempotency (`ON CONFLICT` / get_or_create on reference)
- [ ] Atomic room allocation (`UPDATE … WHERE rooms_confirmed < total_rooms`)
- [ ] On success: send confirmation email + SMS (reuse `website/notifications.py`)
- [ ] Generate QR ID card server-side → upload to R2

### A3. Registration surface for July 31 (per D1)
- [ ] Build registration form (multi-step: details → accommodation → cost summary → pay)
- [ ] Wire Paystack inline/checkout on the page
- [ ] Confirmation screen with QR + receipt

### A4. Test & go live
- [ ] End-to-end test with Paystack **test** keys
- [ ] Verify webhook idempotency (replay a charge) + room-sold-out path
- [ ] Switch to Paystack **live** keys
- [ ] Final dry run; registration LIVE ✅ (target: by ~Jul 24, 1-week buffer)

---

## 🟦 TRACK B — Full JCF App (parallel + after July 31)

### B1. Auth & members
- [ ] Add `djangorestframework-simplejwt`; configure RS256
- [ ] Decide Contact↔app-user link; add registration/login endpoints under `/api/mobile/v1/auth/`
- [ ] Refresh-token rotation + `/auth/refresh`
- [ ] Flutter: login + register screens
- [ ] Flutter: JWT stored via `flutter_secure_storage`; refresh-on-401 in Dio interceptor
- [ ] Flutter: profile screen
- [ ] Auth-gated router shell (go_router redirect)

### B2. Retreat flow in Flutter
- [ ] `RetreatConfigProvider` (Riverpod `AsyncNotifier`)
- [ ] Hive cache for retreat config (1h TTL) + offline fallback
- [ ] 4-step registration form widgets
- [ ] Live cost summary (computed from Riverpod state)
- [ ] `flutter_paystack_max` integration (card + MoMo)
- [ ] Confirmation + QR screen
- [ ] Persist in-progress form state across app restarts (Hive)

### B3. Teachings & content
- [ ] Backend: teaching media URLs, `TeachingSeries`, `TeachingProgress`, `Bookmark`
- [ ] API endpoints for list/detail/series/progress
- [ ] Flutter: teachings list + detail + media player
- [ ] Offline download of teachings (Hive + R2 URLs)

### B4. Engagement
- [ ] Create Firebase project; enable Cloud Messaging
- [ ] Add `google-services.json` / `GoogleService-Info.plist` (gitignored)
- [ ] Backend: device token registration + announcement/notification models
- [ ] Server-side FCM send (service account)
- [ ] Flutter: `firebase_messaging`, foreground/background handlers
- [ ] Appointments (extend existing `Consultation` model) + booking screen

### B5. Journey & service
- [ ] Backend: `innerspace_progress`, `practice_logs`
- [ ] Backend: `service_logs`, `service_tasks`, `children_records`, `farm_logs`
- [ ] Flutter: InnerSpace path UI + practice logging
- [ ] Desktop admin screens for service/records management

### B6. Packaging & release
- [ ] Bundle fonts (Cormorant Garamond, Inter) in `jcf_ui` + register in pubspecs
- [ ] CI: GitHub Actions — `flutter analyze` + `flutter test` on PR
- [ ] CI: build artifacts (APK / IPA / desktop)
- [ ] App icons + splash for all platforms
- [ ] Apple Developer + Google Play accounts set up
- [ ] TestFlight (iOS) + Play internal testing (Android)
- [ ] Store listings, privacy policy, screenshots
- [ ] Public submission → review → launch
- [ ] Desktop installers: Inno Setup `.exe` + macOS `.dmg`
- [ ] Distribution plan for admin desktop installers (per handoff Q6)

---

## Cross-cutting / always-on
- [ ] Keep `flutter analyze` + `flutter test` green on every change
- [ ] No hardcoded fees/dates/tiers in Flutter — all from API
- [ ] Secrets never in Flutter (Paystack secret, R2, JWT private key — backend only)
- [ ] Run migrations on a staging DB before production
