# JCF App — Product Feature Plan

The planned feature set for the JCF platform — the mobile app (members, students,
guests) and its admin, the JCFAdmin dashboard. This is the product vision;
`DEVELOPMENT_CHECKLIST.md` tracks build order and `HANDOVER.md` covers
architecture. Benchmark: the **Sadhguru app (Isha Foundation)** — guided
practices, sadhana support with streaks/reminders, daily wisdom, exclusive
content tier, chants/music, program finder — adapted to JCF's context (Ghana,
centres, the InnerSpace path, the master's consultations, JCF Organic).

- **Updated:** 2026-09-19
- Access tiers everywhere: **guest** (no sign-in) → **member** → **student**.
  Members/students sign in with phone or email → one-time code (Arkesel SMS /
  email), matched to an approved `Contact` in JCFAdmin (`is_member` /
  `is_student`); the session token is bound to that Contact. No passwords, no
  self-service account creation. Guests browse general content immediately.

---

# MOBILE APP — six pillars

## 1. Learn — wisdom & teachings

The content home; the reason a guest keeps the app installed.

- **Teachings library** — video, audio, and written teachings; searchable and
  filterable by topic, format, language. General content free to guests;
  **premium tier** (the "JCF Exclusive" equivalent) for members/students.
- **Series & levels** — teachings organized into ordered series/courses with
  prerequisites, not a flat list. A structured "start here" path for newcomers.
- **Daily Inspiration** — one short teaching/quote from the master each day on
  the Home screen + optional push; shareable as a branded quote card
  (Sadhguru's "Daily Mystic Quote" pattern — cheap, high retention).
- **In-app media player** — audio/video with background playback, resume,
  playback speed; no bouncing to YouTube for core content.
- **Music & chants** — a chants/devotional audio section (Sounds of Isha
  pattern); playlists; optional **wake-up-to-chant alarm**.
- **Offline downloads** — download teachings/chants for offline listening
  (rural connectivity matters in Ghana).
- **Bookmarks & history** — save teachings, continue where you left off.
- **Wallpapers / media kit** — downloadable JCF wallpapers and images.

## 2. Practice — the InnerSpace path

The daily-practice engine; JCF's equivalent of Isha's sadhana support. This is
what makes the app a companion rather than a content shelf.

- **Guided practices** — the foundation's meditations/practices as guided
  audio sessions, tiered: a free intro practice for everyone (Isha Kriya
  pattern), initiated practices unlocked per student level.
- **Daily practice tracker** — log each day's practice (one tap or timer),
  **streaks**, calendar heat-map history, gentle reminders at the member's
  chosen time.
- **InnerSpace journey map** — a visual path through the stages/levels of the
  teaching showing where the student stands and what unlocks next.
- **Self-paced learning** — there are no classes, cohorts, or schedules:
  students work through the lessons entirely at their own pace, any time.
  Structure comes from the content itself (series order, level prerequisites)
  and each student's own progress — never from a timetable.
- **Certificates** — issued on level completion; downloadable, QR-verifiable.

## 3. Programs & events

- **Program finder** — browse programs and events by centre/city/date
  (Isha's Program Finder pattern); public vs members/students-only audiences.
- **Registration & payment** — dynamic per-program registration forms
  (admin-authored each year), fee breakdowns with a **live cost summary** as
  choices change, accommodation tiers with live room availability, group
  registration (register N people), Paystack payment (card + MoMo).
  Registration is **atomic and idempotent**: safe room allocation
  (`UPDATE … WHERE rooms_confirmed < total_rooms`) — no double-booking, no
  double-charge. On success: **email + SMS confirmation** and a **QR ID
  card** generated server-side (stored on R2) for check-in.
- **Retreat = one members-only Program** — the annual retreat is not a
  special case, just a Program. (2026 registration stays on the existing
  website; the app becomes the registration channel from 2027.)
- **My Registrations** — past and upcoming registrations, QR tickets,
  receipts.
- **Events calendar** — centre events and observances with add-to-calendar
  and reminders.
- **Online streaming** — live broadcasts of services, satsangs, and events
  watched inside the app: a "Live now" banner app-wide, a schedule of
  upcoming streams with reminders, audience-targeted streams (public vs
  members/students), viewer counts, and a **replay library** afterwards
  (replays feed the teachings library).
- **Online sessions — meetings & Q&A** — scheduled interactive sessions with
  the master or teachers, each with an audience flag (general public or
  students only):
  - **Q&A sessions**: attendees submit questions in advance or live from the
    app; questions can be upvoted; a moderator curates the queue; the master
    answers on stream. Answered sessions are recorded into the replay
    library.
  - **Online meetings**: smaller live video meetings (e.g. student sessions)
    with join-from-app, RSVP + reminders, and attendance recorded.
  - Infrastructure lean (owner decision): public streams via YouTube Live
    embed; gated streams via a streaming service with signed playback URLs
    (e.g. Cloudflare Stream); meetings via an integrated platform
    (Jitsi / Google Meet / Zoom) with the app owning schedule, RSVP, and
    attendance. Optional per-stream: live chat (moderated) and live giving.
- **Online programs** — paid multi-session online courses (Inner Engineering
  pattern) delivered through the series + payment infrastructure.

## 4. Connect — the foundation & me

- **Consultations** — book appointments with the spiritual master (remote or
  onsite), see status; reminders before the session.
- **Guidance requests** — submit a prayer/guidance/inquiry request; the
  master's guidance returns in-app (mobile counterpart of the Inquiries
  module).
- **Announcements & push notifications** — audience-targeted (public /
  members / students), pinned announcements, personal notification inbox.
- **Centre finder** — all JCF centres on a map with contact info, service
  times, directions.
- **Volunteering** — see service opportunities/tasks, sign up, log service
  hours.
- **Testimonies** — read (and submit) member testimonies, moderated by staff.

## 5. Give & shop

- **Donations** — one-off giving to causes (goal progress bars, impact
  statements); guests can give; members get prefilled details.
- **Recurring giving** — monthly partner pledges via Paystack subscriptions;
  manage/cancel in-app.
- **My Giving** — donation history, yearly totals, receipts.
- **JCF Organic shop** — product catalogue by category (images, price,
  stock), cart (persists across restarts), checkout with delivery or centre
  pickup, Paystack payment, **My Orders** with status tracking
  (pending → paid → fulfilled/delivered). Guests can buy.

## 6. Me — profile & account

- **Profile** — name, photo, centre, Member/Student status; self-service
  edits (phone, contact details) with admin approval.
- **Digital membership card** — QR member ID for check-ins and verification.
- **My activity** — registrations, orders, giving, downloads in one place.
- **Settings** — language (see **Multi-language support** below), notification
  preferences, practice reminder times.

---

# Multi-language support (cross-cutting, mobile)

A first-class requirement, not a settings afterthought — the app is built for
a **worldwide audience** from day one, the way the Sadhguru app ships in 13
languages. Two distinct layers, switchable independently:

1. **UI language** — every label, button, and message in the app localized
   via Flutter's l10n (ARB files). Target set, added in waves as translations
   are ready:
   - **Wave 1:** English (default), **French, Spanish, German, Portuguese**
   - **Wave 2:** Italian, Russian, Dutch, Arabic, Hindi, Chinese (Simplified)
   - **Home languages:** Twi (Akan), Ewe, Ga, Dagbani, Hausa
   Language picked in onboarding and changeable in Settings; defaults to the
   device locale when supported. RTL layout support (Arabic) from the start —
   retrofitting RTL is far costlier than building with it.
2. **Content language** — teachings, chants, daily inspiration, and
   announcements carry a language tag (the backend's Teaching model already
   has one). Members choose preferred content language(s); lists filter to
   them with an "all languages" toggle; a teaching available in several
   languages shows a language switcher on its detail page.

Rules:
- The API honours the app's language (e.g. `Accept-Language`) for
  server-generated text — validation errors, notification/SMS/email
  templates, program form labels (form schemas get per-language labels).
- Translations are admin-authored in the dashboard (translatable fields on
  announcements, daily inspiration, program forms) — never hardcoded in
  Flutter, so adding a language is a content task, not an app release.
- Untranslated content falls back to English gracefully (never a blank
  screen); the UI can ship a language even while content lags behind.
- Fonts/typography verified for all supported scripts from day one.

---

# JCFAdmin — staff & centre operations

Positioning: **JCFAdmin (the Django web dashboard) is the admin for the
mobile app.** All staff features live there — the existing management modules
(members, programs & fees, teachings, causes, announcements, staff, website
content) plus the new consoles below. Staff sign in with staff accounts (not
member OTP), with role-based access. The separate Flutter desktop app is
retired.

## 1. Master's console
- The spiritual master's day view: consultation calendar and the
  guidance-request queue (read, respond, mark answered).

## 2. Content studio
- Upload and manage teachings (bulk media upload to R2 with progress),
  organize series, schedule announcements and daily-inspiration entries ahead
  of time.

## 3. Live session console
- Run online streams and sessions: start/end the broadcast, monitor viewers,
  and manage the **Q&A question queue** — approve, merge duplicates, reorder,
  mark answered as the master responds on stream.
- Schedule sessions (audience: general public or students only), see RSVPs,
  and record attendance for online meetings.
- Moderate live chat when enabled for a stream.

## 4. Reports
- Dashboards: attendance trends, registrations, giving,
  shop sales, practice-adoption per centre; export to CSV/PDF.

---

# Isha → JCF feature mapping (reference)

| Sadhguru app | JCF equivalent |
|---|---|
| Guided meditations (Isha Kriya free; initiated practices gated) | Guided practices — free intro; level-gated for students |
| Sadhana support: progress, streaks, reminders | Daily practice tracker + InnerSpace journey map |
| Daily Mystic Quote / Daily Wisdom | Daily Inspiration card + push |
| Sadhguru Exclusive (premium video) | Premium teachings tier for members/students |
| Sounds of Isha (200+ chants) + wake-up-to-chant | Music & chants + chant alarm |
| Program Finder | Program finder by centre/date |
| Inner Engineering online course | Paid online programs on the series infra |
| Wallpapers, 13 languages | Wallpapers; world languages in waves (EN/FR/ES/DE/PT → more) + Ghanaian home languages |
| Isha Life shop / donations (ecosystem) | JCF Organic shop + giving, in-app |
| — (no equivalent) | Consultations with the master, guidance requests, volunteering, JCFAdmin consoles |

---

# Cross-cutting principles

- Three-tier only: Flutter → Django API → Postgres; no direct DB access.
- All fees/dates/tiers/config from the API at runtime — nothing hardcoded.
- Secrets server-side only; the app only ever receives the **public** Paystack
  key, served at runtime (rotatable without a release); card details never
  touch the app (Paystack hosted page + server verify).
- Payments reuse JCF's **existing Paystack account/keys** (already powering
  website donations); references follow `JCF-{YEAR}-#####` (shop:
  `JCF-SHOP-#####`); webhooks are idempotent and handled in one transaction.
- Offline-tolerant by default: cached content, queued writes where it matters
  (practice logs).
- Every gated surface degrades gracefully for guests with a clear sign-in
  invitation — the guest experience is a funnel, not a wall.
