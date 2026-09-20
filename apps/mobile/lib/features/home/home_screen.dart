import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_models/jcf_models.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../activities/activities_repository.dart';
import '../auth/auth_controller.dart';
import '../engagement/engagement_repository.dart';
import '../../core/coming_soon_screen.dart';
import '../inspiration/inspiration_repository.dart';
import '../lessons/lessons_repository.dart';
import '../practice/practice_repository.dart';
import '../programs/programs_repository.dart';
import 'home_widgets.dart';

/// Role-adaptive Home: guest (design/19), member (design/20), student
/// (design/21). One route, three layouts, chosen by auth state.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(authControllerProvider).asData?.value;
    final Widget body;
    if (member == null) {
      body = const GuestHome();
    } else if (member.isStudent) {
      body = StudentHome(member: member);
    } else {
      body = MemberHome(member: member);
    }
    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(announcementsProvider);
            ref.invalidate(lessonsListProvider);
            ref.invalidate(programsListProvider);
            ref.invalidate(inspirationTodayProvider);
            ref.invalidate(inspirationRecentProvider);
            ref.invalidate(upcomingActivitiesProvider);
            ref.invalidate(continueLearningProvider);
            ref.invalidate(practiceSummaryProvider);
          },
          child: body,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Guest (design/19)
// ---------------------------------------------------------------------------

class GuestHome extends ConsumerWidget {
  const GuestHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final lessons = ref.watch(lessonsListProvider);
    final inspirations =
        ref.watch(inspirationRecentProvider).asData?.value ?? const [];
    final activities =
        ref.watch(upcomingActivitiesProvider).asData?.value ?? const [];

    final publicTeaching = lessons.asData?.value.results
        .where((l) => !l.isLocked)
        .cast<Teaching?>()
        .firstWhere((_) => true, orElse: () => null);
    // Lead with an imminent live session when there is one.
    final nextActivity = activities.isEmpty
        ? null
        : activities.firstWhere((a) => a.liveSoon, orElse: () => activities.first);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        BrandHeader(
          onSearch: () => Navigator.of(context)
              .push(ComingSoonScreen.route(t.searchTitle,
                  icon: Icons.search_rounded)),
          onBell: () => context.push('/announcements'),
        ),
        const SizedBox(height: 14),
        InspirationHeroCarousel(items: inspirations),
        const SizedBox(height: 22),
        SectionTitle(title: t.beginYourJourney, onSeeAll: () => context.go('/more')),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: JourneyCard(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E6BF0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 26),
                ),
                tint: const Color(0xFF2E6BF0),
                bg: const Color(0xFFE3EEFF),
                title: t.watchATeaching,
                sub: t.watchTeachingSub,
                onTap: () => context.go('/lessons'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: JourneyCard(
                leading: const Icon(Icons.self_improvement_rounded,
                    color: Color(0xFFE87F1E), size: 42),
                tint: const Color(0xFFF08A24),
                bg: const Color(0xFFFDEED9),
                title: t.tryAPractice,
                sub: t.tryPracticeSub,
                onTap: () => context.go('/practice'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: JourneyCard(
                leading: const Icon(Icons.menu_book_rounded,
                    color: Color(0xFF23934E), size: 40),
                tint: const Color(0xFF2E9E5B),
                bg: const Color(0xFFDDF3E4),
                title: t.findAProgramme,
                sub: t.findProgrammeSub,
                onTap: () => context.go('/programs'),
              ),
            ),
          ],
        ),
        if (nextActivity != null) ...[
          const SizedBox(height: 22),
          SectionTitle(
              title: t.liveUpcoming,
              onSeeAll: () => context.push('/activities')),
          const SizedBox(height: 10),
          LiveUpcomingCard(item: nextActivity),
        ],
        if (publicTeaching != null) ...[
          const SizedBox(height: 22),
          SectionTitle(
              title: t.latestPublicTeachings,
              onSeeAll: () => context.go('/lessons')),
          const SizedBox(height: 10),
          TeachingCard(teaching: publicTeaching),
        ],
        const SizedBox(height: 22),
        SignInBanner(
          title: t.signInBanner,
          sub: t.signInBannerSub,
          cta: t.signIn,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Member (design/20)
// ---------------------------------------------------------------------------

class MemberHome extends ConsumerWidget {
  const MemberHome({super.key, required this.member});

  final Member member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final announcements = ref.watch(announcementsProvider);
    final lessons = ref.watch(lessonsListProvider);
    final programs = ref.watch(programsListProvider);
    final inspiration = ref.watch(inspirationTodayProvider).asData?.value;

    final latestLesson = lessons.asData?.value.results
        .cast<Teaching?>()
        .firstWhere((_) => true, orElse: () => null);
    final learning = ref.watch(continueLearningProvider).asData?.value;
    final featuredSeries =
        (learning?.series.isNotEmpty ?? false) ? learning!.series.first : null;
    final nextProgram = programs.asData?.value.results
        .cast<Program?>()
        .firstWhere((_) => true, orElse: () => null);
    final announcement = announcements.asData?.value.results
        .cast<Announcement?>()
        .firstWhere((_) => true, orElse: () => null);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        MemberHeader(member: member, chip: t.memberChip),
        const SizedBox(height: 12),
        GreetingBlock(name: _firstName(member), tagline: t.memberTagline),
        const SizedBox(height: 14),
        InspirationHero(compact: true, inspiration: inspiration),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: EyebrowCard(
                eyebrow: t.continueLearningEyebrow,
                icon: Icons.menu_book_rounded,
                title: featuredSeries?.title ?? latestLesson?.topic ?? t.tabLearn,
                ctaLabel: t.resume,
                onTap: () => featuredSeries != null
                    ? context.push('/learning')
                    : latestLesson == null
                        ? context.go('/lessons')
                        : context.push('/lessons/${latestLesson.slug}'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: EyebrowCard(
                eyebrow: t.upcomingEyebrow,
                icon: Icons.calendar_month_rounded,
                title: nextProgram?.title ?? t.upcomingActivitiesTitle,
                ctaLabel: t.seeAll,
                onTap: () => context.push('/activities'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        QuickActionRow(items: [
          QuickAction(Icons.badge_rounded, const Color(0xFF2E6BF0),
              const Color(0xFFE3EEFF), t.myCard, t.myCardSub,
              () => context.go('/more')),
          QuickAction(Icons.people_alt_rounded, const Color(0xFFF08A24),
              const Color(0xFFFDEED9), t.consultationAction, t.consultationSub,
              () => context.push('/appointments')),
          QuickAction(Icons.favorite_rounded, const Color(0xFF2E9E5B),
              const Color(0xFFDDF3E4), t.giveAction, t.giveSub,
              () => context.push('/give')),
          QuickAction(Icons.groups_rounded, const Color(0xFF7B5BD6),
              const Color(0xFFEAE3FA), t.myGroups, t.myGroupsSub,
              () => context.go('/more')),
        ]),
        if (announcement != null) ...[
          const SizedBox(height: 18),
          AnnouncementCard(announcement: announcement),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Student (design/21) — journey hero fills with real data in later slices.
// ---------------------------------------------------------------------------

class StudentHome extends ConsumerWidget {
  const StudentHome({super.key, required this.member});

  final Member member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final announcements = ref.watch(announcementsProvider);
    final announcement = announcements.asData?.value.results
        .cast<Announcement?>()
        .firstWhere((_) => true, orElse: () => null);
    final practice = ref.watch(practiceSummaryProvider).asData?.value;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        MemberHeader(member: member, chip: t.studentChip, studentStyle: true),
        const SizedBox(height: 12),
        GreetingBlock(
          name: '',
          headline: t.welcomeBackName(_firstName(member)),
          tagline: t.studentTagline,
        ),
        const SizedBox(height: 14),
        JourneyHero(
          eyebrow: t.innerspaceJourneyEyebrow,
          cta: t.continueLesson,
          onTap: () => context.push('/learning'),
        ),
        const SizedBox(height: 14),
        TodaysPracticeCard(
          title: practice?.todaysPractice?.title ?? t.todaysPractice,
          streakLabel:
              practice == null ? null : t.dayStreak(practice.streakDays),
          cta: t.startLabel,
          onTap: () => context.go('/practice'),
        ),
        if (announcement != null) ...[
          const SizedBox(height: 14),
          AnnouncementCard(announcement: announcement),
        ],
      ],
    );
  }
}

String _firstName(Member member) {
  final parts = member.fullName.trim().split(' ');
  return parts.isEmpty ? member.fullName : parts.first;
}
