import 'package:flutter/material.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../home/member_home_widgets.dart' show MemberImage;
import 'learning_models.dart';

const muted = Color(0xFF667085);
const hairline = Color(0xFFE4E7EC);
const progressGreen = Color(0xFF039855);
const warningAmber = Color(0xFFF79009);
const errorRed = Color(0xFFD92D20);
const softBlue = Color(0xFFEAF2FF);

/// Packaged artwork, chosen by the course's category.
///
/// The server sends a category rather than a bundled path, so a new
/// category can be styled without shipping an app update, and one that
/// this build has never heard of falls back to the neutral card instead
/// of a broken image.
String learningAsset(String category) {
  const byCategory = {
    'awareness': 'awareness_course',
    'practice': 'mindful_practice_course',
    'communication': 'communication_course',
  };
  final name = byCategory[category] ?? 'recommended_course';
  return 'assets/images/continue_learning/continue_learning_$name.webp';
}

const resumeBannerAsset =
    'assets/images/continue_learning/continue_learning_resume_course_banner.webp';

String lessonTypeLabel(AppLocalizations t, LessonType type) => switch (type) {
      LessonType.video => t.learnTypeVideo,
      LessonType.audio => t.learnTypeAudio,
      LessonType.written => t.learnTypeWritten,
      LessonType.reflection => t.learnTypeReflection,
      LessonType.practice => t.learnTypePractice,
      LessonType.quiz => t.learnTypeQuiz,
      LessonType.live => t.learnTypeLive,
      LessonType.resource => t.learnTypeResource,
    };

IconData lessonTypeIcon(LessonType type) => switch (type) {
      LessonType.video => Icons.play_circle_outline_rounded,
      LessonType.audio => Icons.headphones_rounded,
      LessonType.written => Icons.menu_book_rounded,
      LessonType.reflection => Icons.self_improvement_rounded,
      LessonType.practice => Icons.spa_rounded,
      LessonType.quiz => Icons.quiz_rounded,
      LessonType.live => Icons.sensors_rounded,
      LessonType.resource => Icons.description_rounded,
    };

String downloadLabel(AppLocalizations t, DownloadState state) =>
    switch (state) {
      DownloadState.downloaded => t.learnDownloadDownloaded,
      DownloadState.downloading => t.learnDownloadDownloading,
      DownloadState.queued => t.learnDownloadQueued,
      DownloadState.paused => t.learnDownloadPaused,
      DownloadState.failed => t.learnDownloadFailed,
      DownloadState.expired => t.learnDownloadExpired,
      DownloadState.updateRequired => t.learnDownloadUpdate,
      _ => '',
    };

/// The button on the resume hero. Derived from the server's status, never
/// from a guess about what the member probably wants.
String resumeCtaLabel(AppLocalizations t, LessonSummary lesson) {
  if (!lesson.access.allowed) return t.learnViewAccess;
  if (lesson.download.state == DownloadState.failed) {
    return t.learnRetryDownload;
  }
  if (lesson.type == LessonType.live) return t.learnJoinLive;
  return switch (lesson.status) {
    LessonStatus.completed => t.learnReviewLesson,
    LessonStatus.inProgress => t.learnContinue,
    _ => t.learnStartLesson,
  };
}

/// How tall a horizontal card rail must be.
///
/// The artwork is a fixed height but everything under it is text, so the
/// rail grows with the reader's type size. A fixed number fits exactly one
/// text scale and clips at every larger one.
double cardRailHeight(BuildContext context,
    {required double image, required double text}) {
  final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
  return image + text * scale;
}

/// A progress bar that reads as progress without relying on colour alone —
/// the percentage is always written beside it.
class LearningProgressBar extends StatelessWidget {
  const LearningProgressBar({
    super.key,
    required this.percent,
    this.height = 6,
    this.background = const Color(0xFFE4E7EC),
    this.foreground = JcfColors.skyPrimary,
  });

  final int percent;
  final double height;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final value = clampPercent(percent) / 100;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: background,
          valueColor: AlwaysStoppedAnimation(foreground),
        ),
      ),
    );
  }
}

/// The wide 8:3 card at the top of the screen.
class ResumeLearningHero extends StatelessWidget {
  const ResumeLearningHero({
    super.key,
    required this.lesson,
    required this.onContinue,
  });

  final LessonSummary lesson;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final remaining = lesson.remainingSeconds;
    final minutes = remaining == null ? null : (remaining / 60).ceil();
    final cta = resumeCtaLabel(t, lesson);

    return Semantics(
      button: true,
      label: t.learnSemanticCourse(
        lesson.courseTitle.isEmpty ? lesson.title : lesson.courseTitle,
        lesson.progressPercentage,
        lesson.title,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: JcfColors.cosmicDeep,
          child: InkWell(
            onTap: onContinue,
            child: AspectRatio(
              aspectRatio: 8 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MemberImage(
                    url: lesson.courseImageUrl.isNotEmpty
                        ? lesson.courseImageUrl
                        : lesson.imageUrl,
                    asset: resumeBannerAsset,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  // One gradient across the whole frame so the artwork and
                  // the text read as a single card.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x33102454),
                          Color(0xB3102454),
                          Color(0xF2102454),
                        ],
                        stops: [0, 0.45, 1],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          t.learnResumeLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                            color: JcfColors.gold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          lesson.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (lesson.contextLine.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            lesson.contextLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11.5, color: Color(0xFFD9E3FF)),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: LearningProgressBar(
                                percent: lesson.progressPercentage,
                                background: const Color(0x4DFFFFFF),
                                foreground: JcfColors.gold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t.learnPercentComplete(
                                  lesson.progressPercentage),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (minutes != null && minutes > 0) ...[
                              const Icon(Icons.schedule_rounded,
                                  size: 13, color: Color(0xFFD9E3FF)),
                              const SizedBox(width: 4),
                              Text(
                                t.learnRemaining(minutes),
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFFD9E3FF)),
                              ),
                            ],
                            const Spacer(),
                            FilledButton(
                              onPressed: onContinue,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: JcfColors.cosmicDeep,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                minimumSize: const Size(0, 40),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(999)),
                                textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700),
                              ),
                              child: Text(cta),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The compact statistics card. Deliberately not a leaderboard: no ranks,
/// no comparison, and a zero streak carries no admonishment.
class LearningSummaryCard extends StatelessWidget {
  const LearningSummaryCard({super.key, required this.summary});

  final LearningSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final stats = <(IconData, String, String)>[
      (Icons.check_circle_outline_rounded, '${summary.completedLessons}',
          t.learnSummaryLessons),
      (Icons.local_fire_department_outlined, '${summary.currentStreakDays}',
          t.learnSummaryStreak),
      (Icons.download_done_rounded, '${summary.downloadedItems}',
          t.learnSummaryDownloads),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hairline),
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0)
              Container(width: 1, height: 34, color: hairline),
            Expanded(
              child: Semantics(
                label: '${stats[i].$2} ${stats[i].$3}',
                excludeSemantics: true,
                child: Column(
                  children: [
                    Icon(stats[i].$1, size: 18, color: JcfColors.skyPrimary),
                    const SizedBox(height: 5),
                    Text(
                      stats[i].$2,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: JcfColors.inkOnLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stats[i].$3,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 10.5, color: muted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A section heading with an optional trailing action.
class LearningSectionTitle extends StatelessWidget {
  const LearningSectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: JcfColors.inkOnLight,
                ),
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: JcfColors.skyPrimary,
                minimumSize: const Size(48, 40),
                textStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              child: Text(actionLabel!),
            ),
        ],
      );
}

class ActiveCourseCard extends StatelessWidget {
  const ActiveCourseCard({
    super.key,
    required this.course,
    required this.onOpen,
  });

  final ActiveCourse course;
  final VoidCallback onOpen;

  String _cta(AppLocalizations t) => switch (course.status) {
        CourseProgressStatus.notStarted => t.learnStartCourse,
        CourseProgressStatus.inProgress => t.learnContinue,
        CourseProgressStatus.completed => t.learnReviewCourse,
        CourseProgressStatus.expired => t.learnViewAccess,
        _ => t.learnViewCourse,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final counts = course.totalModules > 0
        ? t.learnLessonCount(course.totalModules, course.totalLessons)
        : t.learnLessonsOnly(course.totalLessons);

    return Semantics(
      button: true,
      label: t.learnSemanticCourse(
          course.title, course.progressPercentage, counts),
      excludeSemantics: true,
      child: SizedBox(
        width: 248,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: MemberImage(
                      url: course.imageUrl,
                      asset: learningAsset(course.category),
                      width: 248,
                      height: 112,
                    ),
                  ),
                  // Expanded, so the text block takes exactly what the
                  // artwork leaves and distributes it. A card sized by its
                  // content overflows the rail the moment a title runs long
                  // or the reader enlarges their type.
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              course.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                                color: JcfColors.inkOnLight,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              counts,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11.5, color: muted),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: LearningProgressBar(
                                    percent: course.progressPercentage),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${course.progressPercentage}%',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: JcfColors.inkOnLight,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (course.status ==
                                  CourseProgressStatus.expired)
                                _StatusChip(
                                  label: t.learnStatusExpired,
                                  foreground: errorRed,
                                  background: const Color(0xFFFDE8E8),
                                  icon: Icons.lock_clock_rounded,
                                )
                              else if (course.status ==
                                  CourseProgressStatus.paused)
                                _StatusChip(
                                  label: t.learnStatusPaused,
                                  foreground: const Color(0xFF8A4B00),
                                  background: const Color(0xFFFDEED9),
                                  icon: Icons.pause_circle_outline_rounded,
                                )
                              else if (course.status ==
                                  CourseProgressStatus.completed)
                                _StatusChip(
                                  label: t.learnStatusCompleted,
                                  foreground: progressGreen,
                                  background: const Color(0xFFDDF3E4),
                                  icon: Icons.check_circle_rounded,
                                ),
                              const Spacer(),
                              Flexible(
                                child: Text(
                                  _cta(t),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: JcfColors.skyPrimary,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  size: 18, color: JcfColors.skyPrimary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
    this.flexibleLabel = false,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  /// Lets a long label ellipsize instead of overflowing. Only safe where
  /// the parent gives the chip a bounded width — inside a Wrap the row is
  /// unbounded and a flex child cannot be measured.
  final bool flexibleLabel;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: 1,
      overflow: flexibleLabel ? TextOverflow.ellipsis : TextOverflow.clip,
      style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: foreground),
    );
    return Container(
      padding: EdgeInsets.fromLTRB(icon == null ? 8 : 5, 3, 8, 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: foreground),
            const SizedBox(width: 3),
          ],
          if (flexibleLabel) Flexible(child: text) else text,
        ],
      ),
    );
  }
}

/// One row in Up Next. Every state carries an icon and words, never colour
/// alone.
class UpNextLessonTile extends StatelessWidget {
  const UpNextLessonTile({
    super.key,
    required this.lesson,
    required this.onOpen,
  });

  final LessonSummary lesson;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locked = lesson.isLocked;
    final minutes = lesson.durationSeconds == null
        ? null
        : (lesson.durationSeconds! / 60).ceil();
    final download = downloadLabel(t, lesson.download.state);

    return Semantics(
      button: true,
      enabled: !locked,
      label: [
        lesson.title,
        lessonTypeLabel(t, lesson.type),
        if (lesson.contextLine.isNotEmpty) lesson.contextLine,
        if (locked) t.learnStatusLocked,
        if (lesson.isCompleted) t.learnStatusCompleted,
      ].join('. '),
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: hairline),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _leading(locked),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          color: locked
                              ? muted
                              : JcfColors.inkOnLight,
                        ),
                      ),
                      if (lesson.contextLine.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          lesson.contextLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 11.5, color: muted),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _meta(lessonTypeIcon(lesson.type),
                              lessonTypeLabel(t, lesson.type)),
                          if (minutes != null)
                            _meta(Icons.schedule_rounded, '$minutes min'),
                          if (locked)
                            _StatusChip(
                              label: t.learnStatusLocked,
                              foreground: const Color(0xFF6B4A00),
                              background: const Color(0xFFFBF0D5),
                              icon: Icons.lock_rounded,
                            )
                          else if (lesson.isCompleted)
                            _StatusChip(
                              label: t.learnStatusCompleted,
                              foreground: progressGreen,
                              background: const Color(0xFFDDF3E4),
                              icon: Icons.check_circle_rounded,
                            )
                          else if (lesson.progressPercentage > 0)
                            _StatusChip(
                              label: t.learnPercentComplete(
                                  lesson.progressPercentage),
                              foreground: JcfColors.skyPrimary,
                              background: softBlue,
                            ),
                          if (download.isNotEmpty)
                            _StatusChip(
                              label: download,
                              foreground:
                                  lesson.download.state ==
                                          DownloadState.failed
                                      ? errorRed
                                      : muted,
                              background: const Color(0xFFF1F3F8),
                              icon: lesson.download.isAvailableOffline
                                  ? Icons.offline_pin_rounded
                                  : Icons.downloading_rounded,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  locked ? Icons.lock_rounded : Icons.chevron_right_rounded,
                  size: 19,
                  color: muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _leading(bool locked) {
    if (lesson.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: MemberImage(
          url: lesson.imageUrl,
          asset: learningAsset(lesson.courseCategory),
          width: 56,
          height: 56,
        ),
      );
    }
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: locked ? const Color(0xFFF1F3F8) : softBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        lessonTypeIcon(lesson.type),
        size: 22,
        color: locked ? muted : JcfColors.skyPrimary,
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: muted),
          const SizedBox(width: 3),
          Text(text, style: const TextStyle(fontSize: 11.5, color: muted)),
        ],
      );
}

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onOpen,
  });

  final CourseRecommendation recommendation;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final counts = recommendation.moduleCount > 0
        ? t.learnLessonCount(
            recommendation.moduleCount, recommendation.lessonCount)
        : t.learnLessonsOnly(recommendation.lessonCount);

    return SizedBox(
      width: 214,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: MemberImage(
                    url: recommendation.imageUrl,
                    asset: learningAsset(recommendation.category),
                    width: 214,
                    height: 96,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            recommendation.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                              color: JcfColors.inkOnLight,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            counts,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontSize: 11, color: muted),
                          ),
                        ),
                        if (recommendation.recommendationReason.isNotEmpty)
                          Flexible(
                            child: Row(
                              children: [
                                Flexible(
                                  child: _StatusChip(
                                    label: recommendation
                                        .recommendationReason,
                                    foreground: JcfColors.skyPrimary,
                                    background: softBlue,
                                    icon: Icons.auto_awesome_rounded,
                                    flexibleLabel: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                t.learnViewCourse,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: JcfColors.skyPrimary,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                size: 18, color: JcfColors.skyPrimary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LearningSkeleton extends StatelessWidget {
  const LearningSkeleton({super.key});

  static Widget block(double width, double height, {double radius = 8}) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFEDF1F8),
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 8 / 3,
            child: block(double.infinity, double.infinity, radius: 20),
          ),
          const SizedBox(height: 20),
          block(double.infinity, 84, radius: 16),
          const SizedBox(height: 26),
          block(150, 16),
          const SizedBox(height: 12),
          Row(
            children: [
              block(248, 224, radius: 16),
              const SizedBox(width: 12),
              Expanded(child: block(double.infinity, 224, radius: 16)),
            ],
          ),
          const SizedBox(height: 26),
          block(110, 16),
          const SizedBox(height: 12),
          for (var i = 0; i < 3; i++) ...[
            block(double.infinity, 82, radius: 14),
            const SizedBox(height: 10),
          ],
        ],
      );
}

/// An empty or failed state, with one thing to do about it.
class LearningPlaceholder extends StatelessWidget {
  const LearningPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            horizontal: 24, vertical: compact ? 24 : 40),
        decoration: compact
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: hairline),
              )
            : null,
        child: Column(
          children: [
            Container(
              width: compact ? 48 : 62,
              height: compact ? 48 : 62,
              decoration: const BoxDecoration(
                  color: softBlue, shape: BoxShape.circle),
              child: Icon(icon,
                  size: compact ? 22 : 28, color: JcfColors.skyPrimary),
            ),
            SizedBox(height: compact ? 10 : 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 14.5 : 16,
                fontWeight: FontWeight.w700,
                color: JcfColors.inkOnLight,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, height: 1.45, color: muted),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: JcfColors.skyPrimary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 12),
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      );
}
