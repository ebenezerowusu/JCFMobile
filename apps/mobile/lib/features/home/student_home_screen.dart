import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../activities/activities_repository.dart';
import 'home_widgets.dart';
import 'student_home_repository.dart';
import 'student_home_widgets.dart';

const _sub = Color(0xFF667085);
const _green = Color(0xFF53A66F);
const _amber = Color(0xFFF79009);
const _red = Color(0xFFD92D20);
const _assetRoot = 'assets/images/student_home';

/// Authenticated student home. One aggregate call drives every section;
/// restricted enrolments explain themselves rather than erroring.
class StudentHomeBody extends ConsumerWidget {
  const StudentHomeBody({super.key});

  /// Server destination identifiers → known routes. A raw route string from
  /// the API is never navigated to.
  void _go(BuildContext context, StudentDestination destination,
      {String? id}) {
    switch (destination) {
      case StudentDestination.lesson:
        id == null ? context.go('/lessons') : context.push('/lessons/$id');
      case StudentDestination.practice:
        context.go('/practice');
      case StudentDestination.program:
        context.push('/learning');
      case StudentDestination.liveClass:
        context.push('/activities');
      case StudentDestination.milestone:
        context.push('/learning');
      case StudentDestination.mentor:
        context.push('/appointments');
      case StudentDestination.announcement:
        context.push('/announcements');
      case StudentDestination.unknown:
        context.go('/more');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final home = ref.watch(studentHomeProvider);
    final payload = home.asData?.value;

    if (payload == null) {
      if (home.hasError) {
        return _FullPageError(onRetry: () => ref.invalidate(studentHomeProvider));
      }
      return const StudentHomeSkeleton();
    }

    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 600 ? (width - 560) / 2 : 20.0;
    final enrolment = payload.primaryEnrolment;
    final restriction = payload.restriction;
    final course = payload.continueCourse;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
          sliver: SliverList.list(children: [
            StudentHomeHeader(
              summary: payload.summary,
              unreadCount: payload.unreadNotificationCount,
            ),

            // A paused, expired or finished enrolment is explained, not hidden.
            if (restriction != null) ...[
              const SizedBox(height: 14),
              StudentRestrictionCard(restriction: restriction),
            ],

            if (enrolment != null) ...[
              const SizedBox(height: 14),
              StudentProgramHero(
                enrolment: enrolment,
                showAllPrograms: payload.activeEnrolments.length > 1,
                onContinue: () => _go(
                    context,
                    course?.destination ?? StudentDestination.program,
                    id: course?.lessonId),
                onViewAll: () => context.go('/programs'),
              ),
            ],

            // --- Today's Learning ---
            if (course != null || payload.assignedPractices.isNotEmpty) ...[
              const SizedBox(height: 26),
              SectionTitle(title: t.todaysLearning),
              const SizedBox(height: 10),
              _TodayRow(payload: payload, onOpen: _go),
            ],

            // --- Next live class ---
            if (payload.nextLiveClass case final liveClass?) ...[
              const SizedBox(height: 26),
              SectionTitle(
                title: t.nextLiveClass,
                onSeeAll: () => context.push('/activities'),
              ),
              const SizedBox(height: 10),
              StudentLiveClassCard(
                liveClass: liveClass,
                onTap: () => _go(context, liveClass.destination),
                onReminder: () => _toggleReminder(context, ref, liveClass),
              ),
            ],

            // --- Progress ---
            const SizedBox(height: 26),
            SectionTitle(
              title: t.yourProgressTitle,
              onSeeAll: () => context.push('/learning'),
            ),
            const SizedBox(height: 10),
            StudentProgressSummary(progress: payload.progress),

            // --- Milestone ---
            if (payload.nextMilestone case final milestone?) ...[
              const SizedBox(height: 26),
              StudentMilestoneCard(
                milestone: milestone,
                onTap: () => _go(context, milestone.destination),
              ),
            ],

            // --- Mentor ---
            const SizedBox(height: 26),
            SectionTitle(title: t.mentorSupport),
            const SizedBox(height: 10),
            StudentMentorCard(
              mentor: payload.mentor,
              onMessage: () => context.push('/appointments'),
              onView: () => context.push('/appointments'),
            ),

            // --- Updates ---
            if (payload.updates.isNotEmpty) ...[
              const SizedBox(height: 26),
              SectionTitle(
                title: t.importantUpdates,
                onSeeAll: () => context.push('/announcements'),
              ),
              const SizedBox(height: 10),
              for (final update in payload.updates) ...[
                StudentUpdateTile(
                  update: update,
                  onTap: () => _go(context, update.destination),
                ),
                const SizedBox(height: 10),
              ],
            ],

            // --- Quick actions ---
            if (payload.quickActions.isNotEmpty) ...[
              const SizedBox(height: 16),
              StudentQuickActions(actions: payload.quickActions),
            ],
          ]),
        ),
      ],
    );
  }

  Future<void> _toggleReminder(
      BuildContext context, WidgetRef ref, LiveClass liveClass) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final item = ActivityItem(
        kind: 'live',
        title: liveClass.title,
        description: '',
        startsAt: liveClass.startsAt,
        allDay: false,
        venue: liveClass.venue,
        audience: 'students',
        liveSoon: false,
        reminderSet: liveClass.reminderEnabled,
        activityId: liveClass.sessionId,
      );
      final on =
          await ref.read(activitiesRepositoryProvider).toggleReminder(item);
      ref.invalidate(studentHomeProvider);
      ref.invalidate(upcomingActivitiesProvider);
      messenger.showSnackBar(
          SnackBar(content: Text(on ? t.reminderOnSnack : t.reminderOffSnack)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.genericError)));
    }
  }
}

class _TodayRow extends StatelessWidget {
  const _TodayRow({required this.payload, required this.onOpen});

  final StudentHomePayload payload;
  final void Function(BuildContext, StudentDestination, {String? id}) onOpen;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final cards = <Widget>[];

    if (payload.continueCourse case final course?) {
      final cta = course.finished
          ? t.reviewLesson
          : course.started
              ? t.continueLesson
              : t.startLesson;
      final remaining = course.remainingSeconds;
      cards.add(StudentTaskCard(
        imageUrl: course.imageUrl,
        asset: '$_assetRoot/student_home_continue_course.webp',
        eyebrow: t.tabLearn,
        title: course.lessonTitle.isEmpty
            ? course.courseTitle
            : course.lessonTitle,
        subtitle: course.moduleTitle,
        cta: cta,
        tint: JcfColors.skyPrimary,
        percent: course.clampedPercent,
        meta: remaining == null
            ? null
            : t.remainingTime((remaining / 60).round()),
        onTap: () => course.accessGranted
            ? onOpen(context, course.destination, id: course.lessonId)
            : onOpen(context, StudentDestination.program),
      ));
    }

    for (final assignment in payload.assignedPractices) {
      final (statusLabel, statusColor, statusIcon) =
          switch (assignment.status) {
        'overdue' => (t.statusOverdue, _red, Icons.priority_high_rounded),
        'due_soon' => (t.statusDueSoon, _amber, Icons.schedule_rounded),
        'in_progress' => (t.statusInProgress, JcfColors.skyPrimary,
            Icons.play_arrow_rounded),
        'completed' => (t.statusCompleted, _green, Icons.check_rounded),
        'excused' => (t.statusExcused, _sub, Icons.remove_rounded),
        _ => (t.statusNotStarted, _sub, Icons.circle_outlined),
      };
      final cta = switch (assignment.status) {
        'in_progress' => t.continuePracticeCta,
        'completed' => t.reviewPractice,
        'overdue' => t.completeNow,
        _ => t.beginPractice,
      };
      final due = assignment.dueAt;
      cards.add(StudentTaskCard(
        imageUrl: assignment.imageUrl,
        asset: '$_assetRoot/student_home_assigned_practice.webp',
        eyebrow: t.tabPractice,
        title: assignment.title,
        subtitle: assignment.durationSeconds == null
            ? assignment.practiceType
            : t.minutesShort(assignment.durationSeconds! ~/ 60),
        cta: cta,
        tint: _green,
        statusLabel: statusLabel,
        statusColor: statusColor,
        statusIcon: statusIcon,
        meta: due == null
            ? null
            : t.dueLabel(DateFormat('d MMM', locale).format(due)),
        onTap: () =>
            onOpen(context, assignment.destination, id: assignment.practiceId),
      ));
    }

    if (cards.isEmpty) {
      return _EmptyNote(text: t.allCaughtUp);
    }
    if (cards.length == 1) return cards.first;

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
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return SizedBox(
      height: 290 + (scale - 1) * 150,
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
  const _FullPageError({required this.onRetry});

  final VoidCallback onRetry;

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
          child: FilledButton(onPressed: onRetry, child: Text(t.retryLabel)),
        ),
      ],
    );
  }
}
