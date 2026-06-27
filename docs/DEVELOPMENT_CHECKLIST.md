# JCF App — Development Checklist

A follow-along checklist for building the JCF App (Flutter mobile + desktop)
on top of the **JCFAdmin** Django backend.

- **Updated:** 2026-06-27 · **Deadline: full app live by 2026-07-31.** Tiered-access app
  (guests + members/students). 2026 retreat registration itself runs on the EXISTING web —
  the app's retreat feature is built now, used as the channel from 2027.
- Repos: `ebenezerowusu/JCFMobile` (Flutter) · `janprince/JCFAdmin` (backend/API)
- Tick `[x]` as you complete each item.

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

## ✅ DECISIONS (RESOLVED 2026-06-27)

- [x] **Deadline.** FULL app live by **2026-07-31** (tiered lessons + programs + retreat reg + payments + donations).
- [x] **Access tiers.** App is for everyone: **guests browse general lessons with NO sign-in**;
  **members/students log in via phone/email OTP** (matched to an approved `Contact`) to unlock
  **premium lessons** and members-only programs. No passwords, no guest accounts.
- [x] **D1 / 2026 retreat.** 2026 registration runs on the **existing web**, not the app. The app's
  retreat feature is built now and becomes the channel from 2027.
- [x] **D3.** No fixed seed values — fees/dates/tiers are **admin-authored per year** (dynamic).
- [x] **D4.** Paystack: **reuse the existing JCF account/keys** (already powering donations).
- [x] **D5.** Firebase / Apple Developer / Google Play: **none yet** — now URGENT (store lead time vs July 31).
- [x] **Model.** Build a **generalized "Programs"** feature: audience flag (public/members/students)
  + optional dynamic registration form + optional Paystack payment. Retreat = one members-only Program.
- [x] **Lessons.** Teachings get a tier flag (general vs premium); premium gated behind OTP membership.

### Infra status (done this session)
- [x] Neon `dev` branch created from `production`; local `.env` targets `dev` (prod untouched)
- [x] Cloudflare R2 connection fixed (`region_name: 'auto'` in `config/settings.py`) + verified
- [x] Flutter 3.44.4 installed locally; both apps pass analyze + test on the Mac

---

## 🟦 TRACK A — Generalized Programs + registration (no deadline; build properly)

### A0. Member identity (OTP) — prerequisite for members-only programs
- [ ] OTP request endpoint: match phone/email → existing approved `Contact` (`is_member`/`is_student`)
- [ ] Send OTP via Arkesel SMS / email (reuse `website/notifications.py`)
- [ ] OTP verify endpoint → issue session/JWT bound to the Contact
- [ ] Rate-limit + expiry on OTP codes

### A1. Programs domain in JCFAdmin
- [ ] Create `programs` Django app
- [ ] Models: `Program` (audience: public/members/students; type/event), `RegistrationForm`/form
      schema, `AccommodationTier`, `CostLineItem`, `Registration`
- [ ] Dynamic per-year config — admins create a new Program + form each year (no hardcoded values)
- [ ] `makemigrations` + `migrate` **against the Neon `dev` branch first**
- [ ] Register models in Django admin (admins author programs, fees, tiers)

### A2. Registration + payment API
- [ ] New mobile API namespace: `path('api/mobile/v1/', include('mobile_api.urls'))`
- [ ] `GET /api/mobile/v1/programs/` (filter by audience; gate members-only behind OTP auth)
- [ ] `GET /api/mobile/v1/programs/<id>/` → program + dynamic form + tiers (+ public Paystack key)
- [ ] `POST /api/mobile/v1/registrations/initiate` → pending registration + Paystack ref `JCF-{YEAR}-#####`
- [ ] Extend Paystack webhook to handle **registration** charges (not just donations)
- [ ] Atomic transaction + idempotency (get_or_create on reference)
- [ ] Atomic room allocation (`UPDATE … WHERE rooms_confirmed < total_rooms`)
- [ ] On success: send confirmation email + SMS (reuse `website/notifications.py`)
- [ ] Generate QR ID card server-side → upload to R2

### A3. Registration UI (in the Flutter app, for future years)
- [ ] OTP login screen (members/students)
- [ ] Program list (public + members-only once authenticated)
- [ ] Multi-step registration form (driven by the dynamic form schema) → cost summary → pay
- [ ] Confirmation screen with QR + receipt

### A4. Test & go live
- [ ] End-to-end test with Paystack **test** keys
- [ ] Verify webhook idempotency (replay a charge) + room-sold-out path
- [ ] Switch to Paystack **live** keys
- [ ] Final dry run on a future-year program, then enable for members

---

## 🟦 TRACK B — Rest of the app (after Track A)

> Member auth (OTP) and the program registration UI now live in **Track A** (A0/A2/A3).
> Track B is everything else. `RegistrationProvider` should use Hive (config cache + in-progress
> form state) and `flutter_paystack_max` when A3 is built.

### B1. Member profile & app shell
- [ ] Flutter: profile screen for the logged-in member (from their `Contact`)
- [ ] Auth-gated router shell (go_router redirect based on OTP session)
- [ ] Refresh-on-401 in the Dio interceptor (`jcf_api_client`)

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
