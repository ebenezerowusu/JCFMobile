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
- [x] **Auth flow designs 10-13** — phone entry w/ dial-code picker, email
      entry, six-box verify with masked destination + honest 30s resend
      countdown (server-enforced), didn't-receive/resend screen; API returns
      masked_destination/channel/retry_after
- [x] **Auth outcomes designs 15-16** — record-not-found and
      approval-pending screens; request-code now reports
      sent/not_found/pending (per-IP throttled, 10/min, anti-enumeration)
      with Check Again continuing into verification once approved
- [x] **Premium gate (design 14)** — modal card on locked lessons (sign in
      -> returns to the lesson and refetches unlocked); post-first-run
      sign-ins now unwind back to their origin instead of restarting at
      stay-connected
- [x] **Groups (backend + admin + API)** — admin-created groups with
      approval-gated join requests: dashboard pages (`/groups/`, request
      queue, roster), `/api/mobile/v1/groups/` (+ `/mine/`, `/join/`),
      capacity enforcement, in-app decision notifications

---

## 🟦 Track 0R — Main-app redesign epic (designs 19-31)

Studied 2026-09-20. Canonical bottom nav from the comps: **Home · Learn ·
Practice · Programs · More** (supersedes the current 5 tabs and the 4-tab
hint in design 18; "More" = the Quick Actions screen, design 29). The comps
confirm three owner decisions: live chat YES, live giving YES, level
prerequisites YES ("Complete Level 2 to unlock").

- [x] 1. New shell: 5-tab nav + **role-adaptive Home** (guest #19 /
      member #20 / student #21) + Quick Actions "More" screen (#29) —
      v1: inspiration hero carries a built-in quote until step 2; member
      Continue-Learning card shows latest lesson until step 3; student
      journey hero fills with level data in step 4
- [x] 2. Daily Inspiration (#22-23): model+admin+API -> live Home hero,
      detail screen (dated quote card, reflection, related-teaching link),
      share-card generator (Light/Cosmic/Minimal, rendered in-app and
      shared as PNG via the share sheet — download rides the share sheet's
      Save Image)
- [x] 3. Continue Learning (#26): TeachingProgress + recently-viewed API,
      author on Teaching, view counts; screen with stats header, featured +
      small series progress cards, Resume, recently-viewed w/ media filters;
      lesson detail gains Mark-as-complete (explicit until the in-app
      player reports playback); member home card + student hero -> /learning
- [x] 4. Continue Practice (#27): Practice + PracticeLog models, streaks,
      weekly-goal ring, today's practice, practice library + logging;
      student-home Today's Practice card shows real practice + streak.
      Notes: "Mark as done" stands in until an in-app audio player reports
      playback; practice history screen and student-home level %/next-step
      lock still pending (need the journey/levels backend)
- [x] 5. Upcoming Activities (#25): unified feed (programmes+live+practice
      +gatherings) w/ filters, audience chips, per-item reminders; entry
      points on guest/member home + More tile. Notes: reminders are stored
      server-side; push delivery lands with the FCM track
- [x] 6. Announcements screen restyle (#28): /announcements with audience
      filter chips, pinned card, unread dots backed by AnnouncementRead
      (cleared on open); detail bottom sheet; home announcement card links
      through. Guests see no dots (read state is per-member)
- [x] 7. Global search (#30-31): GET /search/ across teachings/practices/
      programmes/events(activities)/centres/announcements (audience-
      filtered, premium flagged locked), logged queries power
      /search/popular/; /search screen with recent chips (on-device),
      category grid, popular list, typed result cards + kind filters.
      Notes: centres open an info sheet until a Find a Centre screen
      exists; "Most Relevant" sort dropdown omitted (single relevance)
- [x] 8. Live Now (#24 + owner spec, Sep 2026): LiveSession on top of
      Activity (stream/replay/chat/access/facilitator), moderated
      LiveChatMessage with server-side sanitising, slow mode, mute, block
      and report, LiveReaction, LiveViewerSession heartbeats, LiveSave;
      GET /events/<id>/live/ withholds the playback URL until access is
      confirmed and the join window opens. App: /live/:eventId focused
      route with waiting room + countdown + backing-off status poll,
      live/replay/ended/cancelled/processing/access states, player
      controls behind a LivePlaybackController interface (video_player),
      chat tab, about tab, reactions, save and canonical-link share.
      DEFERRED, needs owner decisions: real-time chat needs Django
      Channels + ASGI + Redis (polling for now, behind the same cursor
      contract); Picture-in-Picture needs native platform channels;
      quality selection needs an engine that exposes variants; no
      streaming vendor chosen — staff paste any HLS URL
- [x] 9. Member Home rebuild (owner spec, Sep 2026): GET /home/member/
      aggregate (summary, welcome, resumable learning+practice, member-
      exclusive teaching, inspirations, next event, quick actions,
      announcements, unread count) + MemberHomeBody with six packaged
      artworks used as fallbacks behind CMS image URLs. Notes: assets ship
      as .webp not .png (3.1MB -> 389KB); no offline cache or analytics
      layer yet (neither exists in the project); welcome copy is served
      from the API but has no dashboard editor yet; Downloads quick action
      withheld until offline downloads ship
- [x] 10. Student Home rebuild (owner spec, Sep 2026): new `studies` Django
      app (Enrolment, PracticeAssignment with derived statuses, Milestone,
      Mentorship) + one dashboard page; GET /home/student/ aggregate with
      server-computed programme progress, resume lesson, assignment states,
      time-gated live-class join, milestone, mentor and priority updates;
      StudentHomeBody with six packaged artworks behind CMS URLs. Notes:
      assets are .webp not .png (see step 9); paused/expired/suspended
      enrolments are explained in-screen rather than erroring; mentor
      messaging routes to appointments until a messaging feature exists;
      Downloads withheld; no offline cache or analytics layer yet
- [x] 11. Daily Inspiration Detail rebuild (owner spec, Sep 2026):
      DailyInspiration gains slug/category/title/share_excerpt/hero/prompt/
      audio + InspirationBlock (structured body, no raw HTML) +
      InspirationSave/InspirationReflection; GET /inspirations/<id-or-slug>/
      is public (shared links open for anyone) with members-only save and
      reflection endpoints; reading time computed server-side; previous/next
      and related come from the server. App: focused reading route
      /inspirations/:identifier with collapsing app bar, 16:9 hero, block
      reader (unknown blocks skipped safely), pull quote, Pause and Reflect,
      share sheet with a live-rendered 1080px card, related carousel and
      end actions. Notes: assets are .webp (see step 9); audio opens in the
      external handler until an in-app player exists; no offline cache or
      analytics layer yet; deep links work in-app but the OS-level
      https://…/inspirations/<slug> handler still needs store config
- [x] 12. Share Card composer (owner spec, Sep 2026): GET
      /inspirations/<id-or-slug>/share-data/ (public) returns an
      editorially trimmed excerpt, canonical URL, sharing flag and the
      template registry; /inspirations/:id/share-card composer with square
      and story formats, four styles, alignment/colour/size controls,
      logo/source/website switches, Reset, and a preview that is the same
      widget as the export (no upscaling). Save to gallery via `gal`
      (permission asked only on Save; iOS Info.plist + Android manifest
      configured); share sends the PNG plus the canonical link and falls
      back to link-only when rendering fails. Notes: assets .webp (see
      step 9); a template with no artwork for a format is hidden rather
      than stretched; "Light" is both a style and a text colour per the
      spec — section headings and semantic labels disambiguate; no
      analytics layer yet
- [x] 13. Upcoming Activities (owner spec + designs 37-41, Sep 2026):
      Activity extended with activity_type, activity_format, city/country,
      online_platform, facilitator, language, artwork, fee and the
      registration fields; ActivityRegistration (seats + waitlist) and
      ActivitySave (a bookmark that holds no seat) added. GET
      /activities/upcoming/ rebuilt as a keyset page over (starts_at, id)
      with from/to day bounds, the four primary chips, type/language/fee/
      access filters, search, window-wide facet counts and a
      server-selected featured_activity; GET /activities/calendar/?month=
      returns per-day density; /activities/save/ and /activities/register/
      added. App: /activities rebuilt with a locale-aware week selector,
      list/calendar toggle persisted locally, a draft-state filter sheet,
      debounced search, cursor pagination with id dedup and a cursor reset
      on every filter change, optimistic reminder and save, a
      non-optimistic registration, offline first page from disk, and
      empty/loading/error states. 73 backend tests (suite 261 green), 52
      app tests (suite 158 green), analyze clean. Notes and deviations:
      hybrid activities answer to BOTH the Online and the In person chip,
      since they genuinely are both; visibility is a ladder rather than a
      filter (a guest sees members-only activities locked, a member sees
      students-only ones locked, a student sees everything open) but the
      featured banner never advertises something the reader cannot open;
      programmes left this feed, because a union of two tables cannot be
      keyset-paged and a programme is a course rather than a dated card
      with a seat and a format - programmes keep their own screen and
      reminders on them still work; a non-live card opens a detail sheet
      built from the row already in hand rather than a separate screen,
      since nothing further needs fetching; assets are .webp (see step 9);
      no analytics layer yet, and only the unfiltered first page is
      cached offline
- [x] 14. Continue Learning (owner spec + designs 43-47, Sep 2026):
      TeachingSeries gained a category (which picks the packaged artwork),
      a facilitator and a recommendation flag; TeachingModule added between
      series and lesson; Teaching gained lesson_type (video/audio/written/
      reflection/practice/quiz/live/resource, backfilled from media_kind),
      a self-referencing prerequisite and a downloadable flag. GET
      /learning/continue/ returns the resume item, an aggregate summary,
      keyset-paginated active courses and up-next lessons, and
      recommendations; POST /learning/lessons/<id>/progress/ records
      position. App: /learning and /learning/continue open the rebuilt hub
      with a resume hero, summary card, horizontal course rail, Up Next
      rows, recommendations, prerequisite sheet, offline first page and
      loading/empty/error states. 51 backend tests (suite 318 green), 41
      app tests (suite 199 green), analyze clean, strings in all five
      Wave-1 locales. Notes and deviations: assets are .webp (see step 9);
      the server picks the resume lesson and owns all progress, and a
      lapsed streak reads as zero rather than carrying forward; THERE IS
      NO DOWNLOAD MANAGER - every download state is modelled, parsed and
      rendered, but the server reports only not_downloaded/unavailable and
      no file is ever fetched, so offline lesson playback, checksums,
      encrypted storage and the pause/resume/retry actions are still to
      build; likewise there is no offline write queue, so progress made
      offline is not yet synced and conflict resolution is unexercised;
      search and the advanced filter sheet are modelled in LearningFilter
      and wired through the controller but have no UI on this screen yet
      (the app bar's search opens the existing global search); the
      overflow menu shows only Help, because My Downloads, Learning
      History and Completed Courses have no screens and a menu entry that
      opens nothing is worse than no entry; no analytics layer exists, so
      none of the listed events are emitted. The old learning/continue/
      endpoint became learning/summary/, which is what it always was - the
      compact payload the home card reads.
- [x] 15. Splash experience (owner spec + designs 48-49, Sep 2026):
      two-stage. Stage one is the OS launch screen - a static logo on
      #102454, regenerated via flutter_native_splash; it is deliberately
      NOT the cosmic comp, because a full-bleed photograph is letterboxed
      differently on every aspect ratio, which is what produced the bands
      above and below the old launch frame. Stage two is
      StartupSplashScreen at /splash: cosmic background, logo, and native
      localized name/tagline/status - nothing is baked into the artwork.
      GET /bootstrap/ added (version gate, maintenance, validated session,
      allowlisted initial_route). 19 backend tests (suite 337 green), 30
      app tests (suite 229 green), analyze clean, strings in all five
      Wave-1 locales. Notes and decisions: the old hardcoded 2000ms delay
      is gone - a fast launch is held only ~400ms so it does not flash,
      and a slow one says "Still preparing..." after 4s rather than
      spinning forever; a malformed X-App-Version sorts lowest so a bad
      header cannot slip past the version gate, and a client sending no
      header at all is not force-updated; initial_route and the store URL
      are both checked against allowlists, so the API can never navigate
      the app or open an arbitrary link; a first-run user with no network
      goes to onboarding rather than an error, since they have nothing to
      "continue offline" into and the gate re-applies next launch;
      Continue Offline appears only when there is genuinely something
      cached. Deviations: assets are .webp for the background only (121KB
      against 1586KB as PNG) - the logo stays PNG because
      flutter_native_splash generates the native drawables from it;
      splash_screen_ui.png is NOT shipped, per the spec; no analytics
      layer exists so none of the listed bootstrap events are emitted;
      deep-link restoration is not implemented (nothing saves an intended
      route yet); there is no integration-test target in this project, so
      the listed integration cases are covered as widget tests instead.
- [x] 16. Welcome screen (owner spec + design 50, Sep 2026): hero with
      logo and language pill over it, warm-white panel with the invitation,
      two actions and separate Terms/Privacy links. LegalDocument model
      (kind/version/language/published/effective_from) + admin + GET
      /legal/<kind>/ with English fallback. 10 backend tests, 19 app tests
      (suite 248 green), analyze clean, strings in all five Wave-1 locales.
      FLOW CHANGE: the spec places Welcome AFTER onboarding, the reverse of
      what shipped. The startup decision is now onboarding incomplete ->
      /onboarding; signed in -> /home; guest already chosen -> /home;
      otherwise -> /welcome. A new welcome.guest_chosen pref is what stops
      Welcome reappearing every launch - deliberately separate from the
      onboarding flag, since finishing the carousel and deciding how to
      enter are different facts. The old pre-onboarding welcome screen is
      deleted and /language now leads to /welcome. CONSEQUENCE: /path and
      /stay-connected are no longer in the default first-run chain. Their
      routes still work, but /stay-connected was the notification opt-in,
      so that prompt no longer appears anywhere - worth an owner decision.
      Notes: no legal text is invented; the screen renders only what staff
      publish, and says "not published yet" otherwise. Guest mode is purely
      local - no guest-session endpoint was added because guest access
      grants nothing (every protected surface still asks the server), so
      there is nothing to create or store. The logo points at the splash
      asset rather than shipping the same artwork twice. Hero is .webp (see
      step 9); welcome_screen_ui.png is not shipped. No analytics layer, so
      none of the listed events are emitted; deep-link restoration is still
      unimplemented.
- [x] 17. Onboarding rebuilt (owner spec + designs 51-53, Sep 2026): three
      pages (Teachings / InnerSpace / Community & Service) in one PageView
      with per-page hero, logo and Skip over it, warm-white panel, animated
      three-dot indicator, Back hidden on page 1, Skip hidden on page 3,
      Get started on page 3. 25 app tests (suite 273 green), analyze clean,
      strings in all five Wave-1 locales. VERSIONED COMPLETION: the old
      `onboarding_seen` boolean is replaced by `onboarding_seen_version`
      against `currentOnboardingVersion = 1`, so a materially new
      onboarding can be shown later without clearing app data. The old
      boolean is still read and treated as "saw version 1", so nobody who
      already onboarded is asked again; a stored version NEWER than the
      current one also counts as seen, so a downgrade does not drag
      someone back through it. Raise the constant only for genuinely new
      content, never for wording. CONSEQUENCE: onboarding now goes
      straight to /welcome, so /language has left the default chain too -
      joining /path and /stay-connected as orphaned routes. The Welcome
      screen carries a language selector, so language is still reachable
      before sign-in, but the dedicated chooser and the notification
      opt-in now appear nowhere. Worth one owner decision covering all
      three. Notes: heroes are .webp (see step 9); the three
      *_screen_ui.png references are not shipped; the logo points at the
      splash asset rather than a fourth copy of the same artwork; no
      analytics layer, so the listed events are not emitted; completion
      is local-only and never blocks on the network.
- [x] 18. Language Selection (owner spec, Sep 2026): /language-selection
      (first launch, no Back) and /settings/language (Settings, Back
      discards). Header, search, rows with code badge + native name +
      localized name + RTL badge + check, empty state, sticky Continue
      with inline save-failure retry. 39 app tests (suite 312 green),
      analyze clean, strings in all five Wave-1 locales. SINGLE SOURCE:
      the supported-language list existed in TWO places
      (core/locale_prefs supportedAppLocales and welcome_state
      appLanguages). Both now re-export
      features/language_selection/supported_languages.dart, which the
      delegate, the startup resolver, the Welcome picker and this screen
      all read. A test asserts the delegate list and the selectable list
      match exactly. FLOW: language selection now precedes onboarding, so
      the chain is splash -> /language-selection -> /onboarding ->
      /welcome -> home. This RESOLVES the orphaned /language screen
      flagged in steps 16-17; /path and /stay-connected remain orphaned
      (notification opt-in still appears nowhere). Notes and deviations:
      the header artwork arrived after the first pass and is now in place
      as .webp (146KB against 1568KB as PNG); it is drawn with
      Alignment.topCenter because the art is portrait and its globe sits
      in the upper fifth - a default centre crop into a short header band
      showed empty blue and lost the subject entirely; ARABIC AND
      SWAHILI ARE CONFIGURED BUT NOT SELECTABLE, because their ARB files
      do not exist and the spec forbids offering a language whose
      translations are unavailable - RTL support, the RTL badge and the
      resolver are all built and tested against Arabic's config, so
      enabling it is adding app_ar.arb and flipping isFullyTranslated;
      no country flags anywhere (a test counts flag code points and
      asserts zero); the logo points at the splash asset rather than a
      fifth copy; no analytics layer, so the listed events are not
      emitted; profile sync to Django is not implemented (device choice
      is authoritative and local-only).

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
- [x] Refresh-on-401 in the Dio interceptor (was already implemented) +
      session-expired UX (design 17): onSessionExpired hook -> auth state
      reset -> /session-expired screen; backend 401-on-invalid-refresh
      covered by tests
- [x] **Sign-out confirmation (design 18)** — dialog with the
      new-code-needed warning, destructive Sign Out (revokes the token via
      the existing logout endpoint) vs Stay Signed In; wired into Profile.
      Auth design family 9-18 COMPLETE
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
