import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import 'learning_controller.dart';
import 'learning_models.dart';
import 'learning_widgets.dart';

/// Continue Learning (owner spec + designs 43–47).
///
/// A personalised, authenticated hub. Every number on it — progress,
/// streak, completion, what to resume — is the server's; this screen
/// renders and never recomputes.
class ContinueLearningScreen extends ConsumerStatefulWidget {
  const ContinueLearningScreen({super.key});

  @override
  ConsumerState<ContinueLearningScreen> createState() =>
      _ContinueLearningScreenState();
}

class _ContinueLearningScreenState
    extends ConsumerState<ContinueLearningScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    if (position.pixels >= position.maxScrollExtent - 500) {
      ref.read(learningHubProvider.notifier).loadMoreLessons();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    // Everything here is private progress, so a guest is sent to sign in
    // before anything is fetched rather than shown an empty shell.
    if (!ref.watch(isLoggedInProvider)) {
      return Scaffold(
        backgroundColor: JcfColors.skySurface,
        appBar: _appBar(t),
        body: SafeArea(
          child: LearningPlaceholder(
            icon: Icons.lock_outline_rounded,
            title: t.signInToSave,
            body: t.learnEmptyResumeBody,
            actionLabel: t.signIn,
            onAction: () => context.push('/login'),
          ),
        ),
      );
    }

    final state = ref.watch(learningHubProvider);

    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      appBar: _appBar(t),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(learningHubProvider.notifier).load(refresh: true),
          child: _body(t, state),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(AppLocalizations t) => AppBar(
        backgroundColor: JcfColors.skySurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
          color: JcfColors.inkOnLight,
        ),
        title: Text(
          t.learnHubTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: JcfColors.inkOnLight,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/search'),
            tooltip: t.searchTitle,
            icon: const Icon(Icons.search_rounded),
            color: JcfColors.inkOnLight,
          ),
          PopupMenuButton<String>(
            tooltip: t.learnHelp,
            icon: const Icon(Icons.more_vert_rounded,
                color: JcfColors.inkOnLight),
            onSelected: (value) {
              // Downloads and history have no screens yet; the entries stay
              // out of the menu rather than opening a dead end.
              if (value == 'help') context.push('/more');
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'help', child: Text(t.learnHelp)),
            ],
          ),
        ],
      );

  Widget _body(AppLocalizations t, ContinueLearningState state) {
    if (state.loading && !state.hasContent) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: const [LearningSkeleton()],
      );
    }
    if (state.isFatalError) {
      return ListView(
        children: [
          LearningPlaceholder(
            icon: Icons.wifi_off_rounded,
            title: t.learnErrorTitle,
            body: t.learnErrorBody,
            actionLabel: t.learnRetry,
            onAction: () => ref.read(learningHubProvider.notifier).load(),
          ),
        ],
      );
    }

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          sliver: SliverList.list(children: _sections(t, state)),
        ),
      ],
    );
  }

  List<Widget> _sections(AppLocalizations t, ContinueLearningState state) {
    final sections = <Widget>[];

    if (state.fromCache) {
      sections
        ..add(_offlineNotice(t, state))
        ..add(const SizedBox(height: 16));
    }

    // --- resume hero ---
    final resume = state.resumeItem;
    if (resume != null) {
      sections
        ..add(LearningSectionTitle(title: t.learnResumeSection))
        ..add(const SizedBox(height: 10))
        ..add(ResumeLearningHero(
          lesson: resume,
          onContinue: () => _openLesson(resume),
        ));
    } else {
      sections.add(LearningPlaceholder(
        compact: true,
        icon: Icons.play_circle_outline_rounded,
        title: t.learnEmptyResumeTitle,
        body: t.learnEmptyResumeBody,
        actionLabel: t.learnEmptyResumeAction,
        onAction: () => context.go('/lessons'),
      ));
    }

    // --- summary ---
    sections
      ..add(const SizedBox(height: 24))
      ..add(LearningSummaryCard(summary: state.summary));

    // --- active courses ---
    sections
      ..add(const SizedBox(height: 28))
      ..add(LearningSectionTitle(
        title: t.learnActiveCourses,
        actionLabel: state.activeCourses.isEmpty ? null : t.learnSeeAll,
        onAction: state.activeCourses.isEmpty
            ? null
            : () => context.go('/lessons'),
      ))
      ..add(const SizedBox(height: 12));

    if (state.activeCourses.isEmpty) {
      sections.add(LearningPlaceholder(
        compact: true,
        icon: Icons.school_outlined,
        title: t.learnEmptyCoursesTitle,
        body: t.learnEmptyCoursesBody,
        actionLabel: t.learnEmptyCoursesAction,
        onAction: () => context.go('/lessons'),
      ));
    } else {
      sections.add(SizedBox(
        height: cardRailHeight(context, image: 112, text: 132),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            if (metrics.axis == Axis.horizontal &&
                metrics.pixels >= metrics.maxScrollExtent - 200) {
              ref.read(learningHubProvider.notifier).loadMoreCourses();
            }
            return false;
          },
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // Lazy, so a long course list does not build off-screen cards.
            itemCount: state.activeCourses.length +
                (state.hasMoreCourses ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index >= state.activeCourses.length) {
                return const SizedBox(
                  width: 60,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                  ),
                );
              }
              final course = state.activeCourses[index];
              return ActiveCourseCard(
                key: ValueKey('course-${course.courseId}'),
                course: course,
                onOpen: () => _openCourse(course),
              );
            },
          ),
        ),
      ));
    }

    // --- up next ---
    sections
      ..add(const SizedBox(height: 28))
      ..add(LearningSectionTitle(
        title: t.learnUpNext,
        actionLabel: state.filter.isEmpty ? null : t.learnFilterClear,
        onAction: state.filter.isEmpty
            ? null
            : () => ref.read(learningHubProvider.notifier).clearFilters(),
      ))
      ..add(const SizedBox(height: 12));

    if (state.upNextLessons.isEmpty) {
      sections.add(LearningPlaceholder(
        compact: true,
        icon: Icons.task_alt_rounded,
        title: t.learnEmptyUpNextTitle,
        body: t.learnEmptyUpNextBody,
      ));
    } else {
      for (final lesson in state.upNextLessons) {
        sections
          ..add(UpNextLessonTile(
            key: ValueKey('lesson-${lesson.lessonId}'),
            lesson: lesson,
            onOpen: () => _openLesson(lesson),
          ))
          ..add(const SizedBox(height: 10));
      }
      if (state.loadingMoreLessons) {
        sections.add(const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ),
        ));
      }
    }

    // --- recommendations ---
    // Hidden entirely when empty: an empty rail with a heading is noise.
    if (state.recommendations.isNotEmpty) {
      sections
        ..add(const SizedBox(height: 28))
        ..add(LearningSectionTitle(title: t.learnRecommended))
        ..add(const SizedBox(height: 12))
        ..add(SizedBox(
          height: cardRailHeight(context, image: 96, text: 136),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.recommendations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final row = state.recommendations[index];
              return RecommendationCard(
                key: ValueKey('recommendation-${row.courseId}'),
                recommendation: row,
                onOpen: () => context.push('/lessons'),
              );
            },
          ),
        ));
    }

    return sections;
  }

  Widget _offlineNotice(AppLocalizations t, ContinueLearningState state) {
    final locale = Localizations.localeOf(context).toString();
    final saved = state.cachedAt ?? DateTime.now();
    final now = DateTime.now();
    final sameDay = saved.year == now.year &&
        saved.month == now.month &&
        saved.day == now.day;
    final when = sameDay
        ? DateFormat.jm(locale).format(saved)
        : DateFormat('d MMM', locale).add_jm().format(saved);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEED9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 15, color: Color(0xFF8A4B00)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              t.learnOfflineNotice(when),
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFF8A4B00)),
            ),
          ),
        ],
      ),
    );
  }

  // --- navigation -----------------------------------------------------

  void _openLesson(LessonSummary lesson) {
    final t = AppLocalizations.of(context)!;

    if (lesson.prerequisite.blocks) {
      _showPrerequisite(t, lesson);
      return;
    }
    if (!lesson.access.allowed) {
      _snack(lesson.access.isExpired
          ? t.learnStatusExpired
          : t.premiumTeachingSub);
      return;
    }

    // The server names a destination; this maps it to a route the app
    // already owns. A route string from the server is never executed.
    switch (lesson.destination.type) {
      case 'live':
        context.push('/live/${lesson.destination.id}');
      case 'practice':
        context.go('/practice');
      default:
        // Video, audio, written, reflection, quiz and resource all open
        // the lesson screen, which picks its own player from the type.
        context.push('/lessons/${lesson.destination.id}');
    }
  }

  void _openCourse(ActiveCourse course) {
    final t = AppLocalizations.of(context)!;
    if (!course.access.allowed) {
      _snack(t.learnStatusExpired);
      return;
    }
    context.go('/lessons');
  }

  void _showPrerequisite(AppLocalizations t, LessonSummary lesson) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_rounded,
                      size: 20, color: Color(0xFF8A4B00)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.learnPrerequisiteTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: JcfColors.inkOnLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                t.learnPrerequisiteBody(
                    lesson.prerequisite.prerequisiteTitle),
                style: const TextStyle(
                    fontSize: 14, height: 1.5, color: muted),
              ),
              const SizedBox(height: 18),
              if (lesson.prerequisite.prerequisiteLessonId != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      context.push(
                          '/lessons/${lesson.prerequisite.prerequisiteLessonId}');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: JcfColors.skyPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    child: Text(t.learnOpenPrerequisite(
                        lesson.prerequisite.prerequisiteTitle)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}
