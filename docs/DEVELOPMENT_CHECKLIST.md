# JCF App — Development Checklist

Build-order tracker for the JCF platform: the Flutter **mobile app** and its
admin, the **JCFAdmin Django dashboard**. The product vision (every feature in
detail) lives in `FEATURES.md`; architecture & conventions in `HANDOVER.md`.

- **Updated:** 2026-09-19
- **Decision — admin surface:** **JCFAdmin (the Django web dashboard) is the
  admin for the mobile app.** All staff features — programs/fees authoring,
  content studio, master's console, live session console, shop management,
  reports — are built in JCFAdmin. The Flutter desktop app (`apps/desktop`)
  is retired; do not build against it.
- The 2026 retreat ran on the existing website; the app is the registration
  channel from 2027 (no hard deadline — build properly).
- Feature scope is documented in `JCF_App_Feature_Specification.pdf`
  (submitted to the project owner); phases below may shift with the owner's
  decisions (roadmap priority, premium model, streaming/meeting platforms,
  shop delivery scope, translation sourcing).
- Repos: `ebenezerowusu/JCFMobile` (Flutter) · `janprince/JCFAdmin`
  (backend / API / admin dashboard)
- Tick `[x]` as you complete each item.

---

## ✅ Phase 0 — Foundations (DONE)

- [x] JCFAdmin confirmed as backend + admin (Django 6 + DRF, PostgreSQL/Neon)
- [x] Cloudflare R2 media storage; email (Gmail SMTP) + SMS (Arkesel) helpers
- [x] Paystack verify + HMAC webhook; public website API (`/api/…`)
- [x] Flutter monorepo (apps/mobile, packages jcf_ui / jcf_models / jcf_api_client)
- [x] Neon `dev` branch for local work; `flutter analyze` + `flutter test` green

## ✅ Built so far — mobile v0 + backend (verified in code, 2026-09)

- [x] **OTP auth** — request/verify endpoints (`mobile_api`: LoginCode,
      MobileToken), token bound to approved Contact; Flutter login screen,
      secure token store
- [x] **Programs domain** — `programs` app (Program, AccommodationTier,
      CostLineItem, Registration) + admin authoring; audience gating
- [x] **Registration + payment API** — dynamic form schema, Paystack init/
      verify, idempotent references, atomic room allocation, QR to R2
- [x] **Flutter programs flow** — list/detail (fees, tiers, availability),
      register sheet (people stepper, tier picker, dynamic fields), Paystack
      browser flow + verify, confirmation with QR
- [x] **Teachings (v0)** — lessons list/detail, general vs premium gating,
      external media links (YouTube/R2)
- [x] **Donations** — causes list with goal progress, donate sheet, Paystack
      verify (guests can give)
- [x] **Engagement (v0)** — audience-targeted announcements on Home;
      notification inbox with mark-read; appointments list + booking
- [x] **Profile (v0)** — member details, centre, status badges, sign out
- [x] **Onboarding** — splash + 3-page carousel (seen-once)
- [x] **JCFAdmin mobile-app dashboards** — Programs authoring (form-schema
      JSON, fees, tiers, registrations table with cancel/room-free) and
      Engagement (announcements CRUD w/ audience+pin, Send Notification to
      audience or one contact -> mobile inbox); 14 hand-in-hand tests
- [x] **Teachings admin completeness** — tier/series/media/thumbnail
      authoring + Series dashboard pages, matching the Lessons API
- [x] **Sign-in options (design 9)** — Welcome back screen (phone / email /
      guest), restyled localized OTP entry per channel; backend delivers the
      code by SMS (Arkesel) for phone with email fallback
- [x] **Groups (backend + admin + API)** — admin-created groups with
      approval-gated join requests: dashboard pages (`/groups/`, request
      queue, roster), `/api/mobile/v1/groups/` (+ `/mine/`, `/join/`),
      capacity enforcement, in-app decision notifications

---

## 🟦 Track 1 — Learn & Practice (recommended lead pillar)

### 1A. Teachings depth (backend + JCFAdmin)
- [ ] `TeachingSeries` (ordered series/levels, prerequisites) + admin authoring
- [ ] `TeachingProgress` (per-Contact complete/resume position) + API
- [ ] `Bookmark` model + API
- [ ] Daily Inspiration model (scheduled entries) + admin + API
- [ ] Content studio polish in JCFAdmin: bulk media upload to R2 with
      progress, series organizer, schedule announcements/inspiration ahead

### 1B. Teachings depth (Flutter)
- [ ] In-app media player — background audio, resume, speed
- [ ] Series/levels browsing + "Continue learning" card on Home
- [ ] Bookmarks & history
- [ ] Offline downloads (Hive + R2 URLs)
- [ ] Daily Inspiration card on Home + shareable branded quote card
- [ ] Music & chants section; wake-up-to-chant alarm
- [ ] Wallpapers / media kit

### 1C. Practice — the InnerSpace path
- [ ] Backend: guided practice content (tiered: free intro / level-gated),
      `practice_logs`, `innerspace_progress`; admin authoring in JCFAdmin
- [ ] Flutter: guided practice player; daily tracker (one-tap/timer, streaks,
      calendar history, reminder time)
- [ ] Flutter: InnerSpace journey map (levels, what unlocks next)
- [ ] Certificates on level completion — server-generated, QR-verifiable

## 🟦 Track 2 — Programs & events completion

- [ ] **My Registrations screen** (provider exists; no screen yet) — QR
      tickets, receipts
- [ ] Events calendar (backend events exist) — list + add-to-calendar +
      reminders
- [ ] Live cost summary in the register sheet as choices change
- [ ] Refresh-on-401 in the Dio interceptor; auth-gated router redirects
- [ ] Online programs (paid multi-session courses on series + payment infra)

## 🟦 Track 3 — Streaming & online sessions (pending owner decisions 9–12)

- [ ] Backend: Stream/Session models (type, audience, schedule, status),
      question queue (submit, upvote, moderate), RSVP + attendance
- [ ] JCFAdmin: **live session console** — schedule, go live, question queue
      (approve/merge/reorder/mark answered), RSVPs, chat moderation
- [ ] Flutter: "Live now" banner + stream schedule + in-app playback
      (YouTube embed for public; signed URLs for gated — per decision)
- [ ] Flutter: Q&A session flow — submit/upvote questions, statuses
- [ ] Online meetings — integrate chosen platform (Jitsi/Meet/Zoom); app owns
      schedule/RSVP/attendance
- [ ] Replay library; promote replays into teachings

## 🟦 Track 4 — Connect completion

- [ ] Guidance requests — member submits, master answers in-app (extends
      Inquiries); master's console queue in JCFAdmin
- [ ] Consultation reminders (before session)
- [ ] Centre finder — map, contact info, service times (centres data exists)
- [ ] Volunteering — service tasks/opportunities, sign-up, hours logging
- [ ] Testimonies — read + submit with staff moderation
- [ ] Groups Flutter screens — browse groups, request to join (with note),
      my groups, request-status states (API is live)

## 🟦 Track 5 — Give & shop

- [ ] Recurring giving (Paystack subscriptions) + manage/cancel in-app
- [ ] My Giving — history, yearly totals, receipts (link donations to Contact)
- [ ] **Shop backend** — `shop` app: ProductCategory, Product (images→R2,
      stock), Order (`JCF-SHOP-#####`, delivery/pickup), OrderItem; atomic
      stock decrement; webhook handling; email/SMS confirmations
- [ ] **Shop admin in JCFAdmin** — product CRUD, stock, order fulfillment
- [ ] **Shop Flutter** — catalogue, cart (Hive-persisted), checkout
      (delivery/pickup per owner decision 4), My Orders tracking

## 🟦 Track 6 — Me & engagement completion

- [ ] Profile self-service edits (phone, photo, contact) with admin approval
      flow in JCFAdmin
- [ ] Digital membership card (QR member ID)
- [ ] Firebase project + FCM: device tokens (backend models exist),
      server-side send, `firebase_messaging` handlers in Flutter

## 🟦 Track 7 — Multi-language (worldwide)

- [x] Flutter l10n scaffolding (ARB + gen-l10n, delegate wired) — RTL layout
      audit still pending
- [x] Language picker in onboarding (device-locale default; Settings entry
      pending)
- [x] Wave 1 UI translations (EN, FR, ES, DE, PT) for the onboarding flow —
      remaining screens (home, lessons, give, programs, profile) pending
- [ ] Content language preferences + filtering + per-teaching language
      switcher; English fallback everywhere
- [x] API honours `Accept-Language` (LocaleMiddleware + LANGUAGES; built-in
      Django/DRF messages translate; custom API strings gettext-wrapped —
      .po files pending); app sends the header from the chosen locale
- [ ] Translatable content fields authored in JCFAdmin (announcements,
      daily inspiration, program form labels)
- [ ] Wave 2 UI: IT, RU, NL, AR (RTL), HI, ZH · Home: Twi, Ewe, Ga,
      Dagbani, Hausa
- [ ] Translation sourcing per owner decision 7

## 🟦 Track 8 — Reports & analytics (JCFAdmin)

- [ ] Extend dashboard: registrations, giving, shop sales, practice adoption,
      streams/attendance; CSV/PDF export

## 🟦 Track 9 — Packaging & release

- [ ] Bundle fonts (Cormorant Garamond, Inter) in `jcf_ui`
- [ ] CI: GitHub Actions — analyze + test on PR; build artifacts (APK/IPA)
- [ ] App icons + splash; Apple Developer + Google Play accounts (owner
      decision 5 from the old list — accounts/owners still needed)
- [ ] TestFlight + Play internal testing → store listings, privacy policy →
      launch
- [ ] Remove/archive `apps/desktop` from the monorepo (desktop retired)

---

## Cross-cutting / always-on

- [ ] **Translation-first development**: every new screen ships with its
      strings in ARB (all Wave-1 languages) from day one — never hardcoded
      copy "to localize later"; direction-aware widgets (`start`/`end`) only;
      new server-side text (errors, templates, form labels) must honour
      `Accept-Language`
- [ ] **API hand-in-hand**: every mobile feature is built together with its
      JCFAdmin API in the same pass — Django tests + Flutter screen against
      the real endpoint, tested end to end before moving on
- [ ] Keep `flutter analyze` + `flutter test` green on every change
- [ ] No hardcoded fees/dates/tiers/strings in Flutter — all from API/l10n
- [ ] Secrets never in Flutter (Paystack secret, R2, signing keys — server only)
- [ ] Payments idempotent (unique refs; webhook in one transaction)
- [ ] Run migrations on the Neon `dev` branch before `production`
- [ ] Guest-gated surfaces always degrade to a sign-in invitation
