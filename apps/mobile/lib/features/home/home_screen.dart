import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_models/jcf_models.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../activities/home_feed.dart';
import '../auth/auth_controller.dart';
import '../engagement/engagement_repository.dart';
import '../inspiration/inspiration_repository.dart';
import '../lessons/lessons_repository.dart';
import '../practice/practice_repository.dart';
import '../programs/programs_repository.dart';
import 'home_widgets.dart';
import 'student_home_repository.dart';
import 'student_home_screen.dart';

/// Home, in two forms: guest (design/19) and signed in (design/21).
///
/// There used to be three, with a separate member layout between them.
/// The app has two tiers now, so anyone signed in gets the student home
/// whether or not they are enrolled on a course.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(authControllerProvider).asData?.value;
    // Signed in or not. The member/student distinction decides what the
    // server returns, not which home is drawn.
    final Widget body =
        member == null ? const GuestHome() : const StudentHomeBody();
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
            ref.invalidate(studentHomeProvider);
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
          onSearch: () => context.push('/search'),
          onBell: () => context.push('/announcements'),
        ),
        const SizedBox(height: 14),
        InspirationHeroCarousel(items: inspirations),
        const SizedBox(height: 22),
        SectionTitle(title: t.beginYourJourney, onSeeAll: () => context.go('/more')),
        const SizedBox(height: 10),
        SizedBox(
          height: 168,
          child: LayoutBuilder(builder: (context, constraints) {
            // ~44% viewport cards so the next card peeks (scroll affordance).
            final cardWidth = constraints.maxWidth * 0.44;
            final titleSize = journeyTitleSize(
                [t.watchATeaching, t.tryAPractice, t.findAProgramme],
                cardWidth - 20);
            final cards = [
              (
                'assets/images/guest_watch_teaching.webp',
                t.watchATeaching,
                t.watchTeachingSub,
                () => context.go('/lessons'),
              ),
              (
                'assets/images/guest_try_practice.webp',
                t.tryAPractice,
                t.tryPracticeSub,
                () => context.go('/practice'),
              ),
              (
                'assets/images/guest_find_programme.webp',
                t.findAProgramme,
                t.findProgrammeSub,
                () => context.go('/programs'),
              ),
            ];
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) => SizedBox(
                width: cardWidth,
                child: JourneyCard(
                  image: cards[i].$1,
                  title: cards[i].$2,
                  titleSize: titleSize,
                  sub: cards[i].$3,
                  onTap: cards[i].$4,
                ),
              ),
            );
          }),
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
          title: t.alreadyPartOfJcf,
          sub: t.signInBannerSub,
          cta: t.signIn,
        ),
      ],
    );
  }
}
