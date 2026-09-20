import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../core/brand.dart';
import 'lessons_repository.dart';

const _sub = Color(0xFF54689B);

/// Continue Learning (design/26): per-series progress + recently viewed.
class ContinueLearningScreen extends ConsumerStatefulWidget {
  const ContinueLearningScreen({super.key});

  @override
  ConsumerState<ContinueLearningScreen> createState() =>
      _ContinueLearningScreenState();
}

class _ContinueLearningScreenState
    extends ConsumerState<ContinueLearningScreen> {
  String _filter = 'all';

  String _viewedLabel(AppLocalizations t, DateTime when) {
    final days = DateTime.now().difference(when).inDays;
    if (days <= 0) return t.viewedToday;
    if (days == 1) return t.viewedYesterday;
    return t.viewedDaysAgo(days);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final summary = ref.watch(continueLearningProvider);

    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      appBar: AppBar(
        backgroundColor: JcfColors.skySurface,
        elevation: 0,
        foregroundColor: JcfColors.inkOnLight,
        title: Text(
          t.continueLearningTitle,
          style: const TextStyle(
            color: JcfColors.inkOnLight,
            fontFamily: JcfTypography.bodyFamily,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(continueLearningProvider),
            child: Text(t.genericError),
          ),
        ),
        data: (data) {
          if (data == null || (data.series.isEmpty &&
              data.recentlyViewed.isEmpty)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 44,
                      backgroundColor: Color(0xFFE3EEFF),
                      child: Icon(Icons.menu_book_rounded,
                          size: 40, color: JcfColors.skyPrimary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.nothingInProgress,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _sub,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final viewed = data.recentlyViewed
              .where((v) => _filter == 'all' || v.mediaKind == _filter)
              .toList();
          final featured = data.series.isEmpty ? null : data.series.first;
          final others = data.series.skip(1).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(continueLearningProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                // Header stats card.
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const JcfLogo(size: 52),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.activeSeriesCount(data.activeSeries),
                              style: const TextStyle(
                                color: JcfColors.skyPrimary,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              t.lessonsCompletedCount(data.lessonsCompleted),
                              style: const TextStyle(
                                color: _sub,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (featured != null) ...[
                  const SizedBox(height: 14),
                  _FeaturedSeriesCard(series: featured),
                ],
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < others.length && i < 2; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(child: _SmallSeriesCard(series: others[i])),
                      ],
                    ],
                  ),
                ],
                if (data.recentlyViewed.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    t.recentlyViewed,
                    style: const TextStyle(
                      color: JcfColors.inkOnLight,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final (key, label) in [
                        ('all', t.filterAll),
                        ('video', t.filterVideo),
                        ('audio', t.filterAudio),
                      ]) ...[
                        ChoiceChip(
                          label: Text(label),
                          selected: _filter == key,
                          selectedColor: JcfColors.skyPrimary,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: _filter == key
                                ? Colors.white
                                : JcfColors.inkOnLight,
                            fontFamily: JcfTypography.bodyFamily,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) => setState(() => _filter = key),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final lesson in viewed) ...[
                    _ViewedTile(
                      lesson: lesson,
                      subtitle: _viewedLabel(t, lesson.lastViewedAt),
                      completedLabel: t.completedLabel,
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedSeriesCard extends ConsumerWidget {
  const _FeaturedSeriesCard({required this.series});

  final SeriesProgress series;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            series.title,
            style: const TextStyle(
              color: JcfColors.inkOnLight,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            series.author,
            style: const TextStyle(
              color: _sub,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${series.percent}%',
                style: const TextStyle(
                  color: JcfColors.skyPrimary,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: series.percent / 100,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE3EEFF),
                    color: JcfColors.skyPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            t.lessonXofY(series.currentLesson, series.lessonsTotal),
            style: const TextStyle(
              color: _sub,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: series.resumeSlug == null
                ? null
                : () => context.push('/lessons/${series.resumeSlug}'),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(t.resumeLesson),
            style: FilledButton.styleFrom(
              backgroundColor: JcfColors.skyPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
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

class _SmallSeriesCard extends StatelessWidget {
  const _SmallSeriesCard({required this.series});

  final SeriesProgress series;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: series.resumeSlug == null
            ? null
            : () => context.push('/lessons/${series.resumeSlug}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                series.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${series.percent}%',
                    style: const TextStyle(
                      color: JcfColors.skyPrimary,
                      fontFamily: JcfTypography.bodyFamily,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: series.percent / 100,
                        minHeight: 7,
                        backgroundColor: const Color(0xFFE3EEFF),
                        color: JcfColors.skyPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                t.lessonXofY(series.currentLesson, series.lessonsTotal),
                style: const TextStyle(
                  color: _sub,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewedTile extends StatelessWidget {
  const _ViewedTile(
      {required this.lesson, required this.subtitle,
      required this.completedLabel});

  final ViewedLesson lesson;
  final String subtitle;
  final String completedLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/lessons/${lesson.slug}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFE3EEFF),
                child: Icon(
                  lesson.mediaKind == 'audio'
                      ? Icons.headphones_rounded
                      : Icons.play_arrow_rounded,
                  color: JcfColors.skyPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.topic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      [
                        if (lesson.seriesTitle != null) lesson.seriesTitle!,
                        subtitle,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _sub,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (lesson.completed)
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2E9E5B), size: 22)
              else
                const Icon(Icons.chevron_right, color: Color(0xFF9AA7C7)),
            ],
          ),
        ),
      ),
    );
  }
}
