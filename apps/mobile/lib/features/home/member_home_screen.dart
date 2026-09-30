import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../activities/home_feed.dart';
import 'home_widgets.dart';
import 'member_home_repository.dart';
import 'member_home_widgets.dart';

const _sub = Color(0xFF667085);
const _green = Color(0xFF53A66F);

/// Authenticated member home. One aggregate call drives every section;
/// sections with nothing to show are hidden rather than rendered empty.
class MemberHomeBody extends ConsumerWidget {
  const MemberHomeBody({super.key});

  /// Maps a server destination identifier to a known route. Unrecognised
  /// identifiers fall back to a safe in-app screen.
  void _go(BuildContext context, MemberDestination destination,
      {String? id, String? unitId}) {
    switch (destination) {
      case MemberDestination.lesson:
        unitId == null ? context.go('/lessons') : context.push('/lessons/$unitId');
      case MemberDestination.series || MemberDestination.journey:
        context.push('/learning');
      case MemberDestination.practice:
        context.go('/practice');
      case MemberDestination.teaching:
        id == null ? context.go('/lessons') : context.push('/lessons/$id');
      case MemberDestination.event:
        context.push('/activities');
      case MemberDestination.announcement:
        context.push('/announcements');
      case MemberDestination.unknown:
        context.go('/more');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final home = ref.watch(memberHomeProvider);

    // Keep the loaded payload on screen while a refresh is in flight.
    final payload = home.asData?.value;
    if (payload == null) {
      if (home.hasError) return _FullPageError(ref: ref);
      return const MemberHomeSkeleton();
    }

    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 600 ? (width - 560) / 2 : 20.0;
    final name = payload.summary.displayName;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
          sliver: SliverList.list(children: [
            MemberHomeHeader(
              summary: payload.summary,
              unreadCount: payload.unreadNotificationCount,
            ),
            const SizedBox(height: 14),
            MemberWelcomeHero(
              welcome: payload.welcome,
              name: name,
              onTap: () => _go(context, payload.welcome.destination),
            ),

            // --- Continue Your Journey (hidden when nothing is resumable) ---
            if (payload.hasResumable) ...[
              const SizedBox(height: 26),
              SectionTitle(
                title: t.continueYourJourney,
                onSeeAll: () => context.push('/learning'),
              ),
              const SizedBox(height: 10),
              _ResumeRow(payload: payload, onOpen: _go),
            ],

            // --- Member exclusive ---
            if (payload.featuredContent case final featured?) ...[
              const SizedBox(height: 26),
              SectionTitle(title: t.forMembers),
              const SizedBox(height: 10),
              MemberExclusiveCard(
                content: featured,
                onTap: () => _go(context, featured.destination,
                    id: featured.id),
              ),
            ],

            // --- Daily inspiration (same presentation as guest home) ---
            if (payload.inspirations.isNotEmpty) ...[
              const SizedBox(height: 26),
              SectionTitle(title: t.dailyInspiration),
              const SizedBox(height: 10),
              InspirationHeroCarousel(items: payload.inspirations),
            ],

            // --- Live & upcoming ---
            const SizedBox(height: 26),
            SectionTitle(
              title: t.liveUpcoming,
              onSeeAll: () => context.push('/activities'),
            ),
            const SizedBox(height: 10),
            if (payload.featuredEvent case final event?)
              MemberLiveUpcomingCard(
                event: event,
                onTap: () => _go(context, event.destination),
                onReminder: () => _toggleReminder(context, ref, event),
              )
            else
              _EmptyNote(text: t.noUpcomingEvents),

            // --- Quick actions ---
            if (payload.quickActions.isNotEmpty) ...[
              const SizedBox(height: 26),
              SectionTitle(title: t.quickActionsTitle),
              const SizedBox(height: 10),
              MemberQuickActions(actions: payload.quickActions),
            ],

            // --- Community ---
            if (payload.announcements.isNotEmpty) ...[
              const SizedBox(height: 26),
              SectionTitle(
                title: t.communitySection,
                onSeeAll: () => context.push('/announcements'),
              ),
              const SizedBox(height: 10),
              CommunityAnnouncementCard(
                announcement: payload.announcements.first,
                onTap: () => _go(context,
                    payload.announcements.first.destination),
              ),
            ],

            if (payload.isEmpty) ...[
              const SizedBox(height: 40),
              Center(
                child: Text(
                  t.noAnnouncements,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _sub,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ]),
        ),
      ],
    );
  }

  Future<void> _toggleReminder(
      BuildContext context, WidgetRef ref, MemberEvent event) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final on = await ref
          .read(activitiesRepositoryProvider)
          .toggleReminder(
            activityId: event.activityId, programSlug: event.programSlug);
      ref.invalidate(memberHomeProvider);
      ref.invalidate(upcomingActivitiesProvider);
      messenger.showSnackBar(
          SnackBar(content: Text(on ? t.reminderOnSnack : t.reminderOffSnack)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.genericError)));
    }
  }
}

class _ResumeRow extends StatelessWidget {
  const _ResumeRow({required this.payload, required this.onOpen});

  final MemberHomePayload payload;
  final void Function(BuildContext, MemberDestination,
      {String? id, String? unitId}) onOpen;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cards = <Widget>[
      for (final item in payload.continueLearning)
        ResumeCard(
          imageUrl: item.imageUrl,
          asset:
              'assets/images/member_home/member_home_continue_learning.webp',
          eyebrow: t.tabLearn,
          title: item.title,
          subtitle: item.currentUnitTitle.isEmpty
              ? item.subtitle
              : item.currentUnitTitle,
          cta: t.continueLearningCta,
          tint: JcfColors.skyPrimary,
          percent: item.clampedPercent,
          meta: item.totalUnits > 0
              ? t.lessonProgress(item.completedUnits, item.totalUnits)
              : null,
          onTap: () => onOpen(context, item.destination,
              id: item.contentId, unitId: item.currentUnitId),
        ),
      for (final item in payload.continuePractice)
        ResumeCard(
          imageUrl: item.imageUrl,
          asset:
              'assets/images/member_home/member_home_continue_practice.webp',
          eyebrow: t.tabPractice,
          title: item.title,
          subtitle: item.subtitle,
          cta: t.continuePracticeCta,
          tint: _green,
          percent: item.progressPercentage?.clamp(0, 100),
          meta: item.currentStreak > 0
              ? t.dayStreak(item.currentStreak)
              : (item.durationSeconds == null
                  ? null
                  : t.minutesShort(item.durationSeconds! ~/ 60)),
          onTap: () => onOpen(context, item.destination, id: item.practiceId),
        ),
    ];

    if (cards.length == 1) return cards.first;

    // Two columns where there is room, a peeking carousel on small phones.
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 400) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < cards.length && i < 2; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }
    return SizedBox(
      height: 268,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) =>
            SizedBox(width: width * 0.62, child: cards[i]),
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _sub,
          fontFamily: JcfTypography.bodyFamily,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _FullPageError extends StatelessWidget {
  const _FullPageError({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFEAF2FF),
            child: Icon(Icons.cloud_off_rounded,
                size: 36, color: JcfColors.skyPrimary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          t.genericError,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _sub,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(memberHomeProvider),
            child: Text(t.retryLabel),
          ),
        ),
      ],
    );
  }
}
