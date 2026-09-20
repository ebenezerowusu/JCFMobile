import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../core/launch.dart';
import '../auth/auth_controller.dart';
import '../home/home_widgets.dart' show SignInBanner;
import 'practice_repository.dart';

const _sub = Color(0xFF54689B);

(IconData, Color, Color) _categoryLook(String category) => switch (category) {
      'morning' => (Icons.wb_sunny_rounded, const Color(0xFFF08A24),
          const Color(0xFFFDEED9)),
      'breathing' => (Icons.eco_rounded, const Color(0xFF2E9E5B),
          const Color(0xFFDDF3E4)),
      'reflection' => (Icons.nightlight_round, const Color(0xFF7B5BD6),
          const Color(0xFFEAE3FA)),
      _ => (Icons.spa_rounded, JcfColors.skyPrimary, const Color(0xFFE3EEFF)),
    };

/// Practice tab (design/27): today's practice, streak, weekly progress,
/// practice library. Guests see the free-intro library + sign-in banner.
class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final loggedIn = ref.watch(isLoggedInProvider);

    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      body: SafeArea(
        child: loggedIn
            ? const _MemberPractice()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Text(
                    t.tabPractice,
                    style: const TextStyle(
                      color: JcfColors.inkOnLight,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    t.practiceTagline,
                    style: const TextStyle(
                      color: _sub,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _GuestPracticeList(),
                  const SizedBox(height: 18),
                  SignInBanner(
                    title: t.signInBanner,
                    sub: t.signInBannerSub,
                    cta: t.signIn,
                  ),
                ],
              ),
      ),
    );
  }
}

class _GuestPracticeList extends ConsumerWidget {
  const _GuestPracticeList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practices = ref.watch(practiceListProvider);
    return practices.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
      data: (rows) => Column(
        children: [
          for (final practice in rows) ...[
            _PracticeRow(practice: practice, canLog: false),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _MemberPractice extends ConsumerWidget {
  const _MemberPractice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final summary = ref.watch(practiceSummaryProvider);

    return summary.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: FilledButton(
          onPressed: () => ref.invalidate(practiceSummaryProvider),
          child: Text(t.genericError),
        ),
      ),
      data: (data) {
        if (data == null) return const SizedBox.shrink();
        final locale = Localizations.localeOf(context).toString();
        final dayLetter = DateFormat.E(locale);
        final maxCount = data.week
            .fold<int>(1, (acc, day) => day.count > acc ? day.count : acc);

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(practiceSummaryProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                t.continuePracticeTitle,
                style: const TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                t.practiceTagline,
                style: const TextStyle(
                  color: _sub,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 15.5,
                ),
              ),
              const SizedBox(height: 14),
              // Streak + this-week chips.
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.local_fire_department_rounded,
                      tint: const Color(0xFFF08A24),
                      bg: const Color(0xFFFDEED9),
                      title: t.dayStreak(data.streakDays),
                      sub: t.keepGoing,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.bar_chart_rounded,
                      tint: JcfColors.skyPrimary,
                      bg: const Color(0xFFE3EEFF),
                      title: t.practicesCount(data.weekTotal),
                      sub: t.thisWeekShort,
                    ),
                  ),
                ],
              ),
              if (data.todaysPractice != null) ...[
                const SizedBox(height: 14),
                _TodaysPracticeCard(
                    practice: data.todaysPractice!, doneToday: data.doneToday),
              ],
              const SizedBox(height: 14),
              // This Week checkmarks.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.thisWeekTitle,
                      style: const TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final day in data.week)
                          Column(
                            children: [
                              Text(
                                dayLetter.format(day.date).substring(0, 1),
                                style: const TextStyle(
                                  color: _sub,
                                  fontFamily: JcfTypography.bodyFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              day.done
                                  ? const CircleAvatar(
                                      radius: 15,
                                      backgroundColor: JcfColors.skyPrimary,
                                      child: Icon(Icons.check,
                                          size: 17, color: Colors.white),
                                    )
                                  : Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: const Color(0xFFB9C6E2),
                                            width: 2),
                                      ),
                                    ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Your Progress: bars + weekly goal ring.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.yourProgress,
                            style: const TextStyle(
                              color: JcfColors.inkOnLight,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          t.nOfGoalPractices(
                              data.weekDaysDone, data.weeklyGoal),
                          style: const TextStyle(
                            color: _sub,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 90,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                for (final day in data.week)
                                  Container(
                                    width: 16,
                                    height: day.count == 0
                                        ? 8
                                        : 20 + 70 * day.count / maxCount,
                                    decoration: BoxDecoration(
                                      color: day.count == 0
                                          ? const Color(0xFFE3EEFF)
                                          : JcfColors.skyPrimary,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        SizedBox(
                          height: 96,
                          width: 96,
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: data.goalPercent / 100,
                                strokeWidth: 9,
                                backgroundColor: const Color(0xFFE3EEFF),
                                color: JcfColors.skyPrimary,
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${data.goalPercent}%',
                                      style: const TextStyle(
                                        color: JcfColors.inkOnLight,
                                        fontFamily:
                                            JcfTypography.bodyFamily,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      t.weeklyGoal,
                                      style: const TextStyle(
                                        color: _sub,
                                        fontFamily:
                                            JcfTypography.bodyFamily,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                t.yourPractices,
                style: const TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              for (final practice in data.practices) ...[
                _PracticeRow(practice: practice, canLog: true),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.icon, required this.tint, required this.bg,
      required this.title, required this.sub});

  final IconData icon;
  final Color tint;
  final Color bg;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
              radius: 20, backgroundColor: bg, child: Icon(icon, color: tint)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: JcfColors.inkOnLight,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(
                    color: _sub,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaysPracticeCard extends ConsumerWidget {
  const _TodaysPracticeCard(
      {required this.practice, required this.doneToday});

  final Practice practice;
  final bool doneToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3EEFF), Colors.white],
        ),
        border: Border.all(color: const Color(0xFFC6D6F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.todaysPracticeEyebrow,
            style: const TextStyle(
              color: JcfColors.skyPrimary,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 11.5,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            practice.title,
            style: const TextStyle(
              color: JcfColors.inkOnLight,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${t.minutesShort(practice.minutes)} · ${t.guidedAudio}',
            style: const TextStyle(
              color: _sub,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 14.5,
            ),
          ),
          if (practice.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              practice.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _sub,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 14),
          doneToday
              ? Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF2E9E5B)),
                    const SizedBox(width: 8),
                    Text(
                      t.doneToday,
                      style: const TextStyle(
                        color: Color(0xFF2E9E5B),
                        fontFamily: JcfTypography.bodyFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              : FilledButton.icon(
                  onPressed: () => showPracticeSheet(context, ref, practice),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(t.startLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: JcfColors.skyPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: JcfTypography.bodyFamily,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _PracticeRow extends ConsumerWidget {
  const _PracticeRow({required this.practice, required this.canLog});

  final Practice practice;
  final bool canLog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final (icon, tint, bg) = _categoryLook(practice.category);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: canLog
            ? () => showPracticeSheet(context, ref, practice)
            : (practice.audioUrl.isEmpty
                ? null
                : () => openExternalUrl(practice.audioUrl)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                  radius: 22, backgroundColor: bg,
                  child: Icon(icon, color: tint)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      practice.title,
                      style: const TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${t.minutesShort(practice.minutes)} · ${t.guidedAudio}',
                      style: const TextStyle(
                        color: _sub,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9AA7C7)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Practice sheet: play the guided audio and log the session. The explicit
/// "Mark as done" stands in until an in-app audio player reports completion.
void showPracticeSheet(
    BuildContext context, WidgetRef ref, Practice practice) {
  final t = AppLocalizations.of(context)!;
  final (icon, tint, bg) = _categoryLook(practice.category);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 26, backgroundColor: bg,
                  child: Icon(icon, color: tint, size: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      practice.title,
                      style: const TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${t.minutesShort(practice.minutes)} · ${t.guidedAudio}',
                      style: const TextStyle(
                        color: _sub,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (practice.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              practice.description,
              style: const TextStyle(
                color: _sub,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 18),
          if (practice.audioUrl.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => openExternalUrl(practice.audioUrl),
              icon: const Icon(Icons.headphones_rounded),
              label: Text(t.playAudio),
              style: OutlinedButton.styleFrom(
                foregroundColor: JcfColors.skyPrimary,
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: JcfColors.skyPrimary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
            ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(practiceRepositoryProvider).log(practice.id);
              ref.invalidate(practiceSummaryProvider);
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            },
            icon: const Icon(Icons.check_rounded),
            label: Text(t.markDone),
            style: FilledButton.styleFrom(
              backgroundColor: JcfColors.skyPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Small helper used by the student home to jump here.
void goToPractice(BuildContext context) => context.go('/practice');
