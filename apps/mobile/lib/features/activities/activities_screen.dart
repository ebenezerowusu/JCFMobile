import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import 'activities_repository.dart';

const _sub = Color(0xFF54689B);

(IconData, Color, Color) _kindLook(String kind) => switch (kind) {
      'live' => (Icons.people_alt_rounded, const Color(0xFFF08A24),
          const Color(0xFFFDEED9)),
      'practice' => (Icons.self_improvement_rounded, const Color(0xFF2E9E5B),
          const Color(0xFFDDF3E4)),
      'programme' => (Icons.calendar_month_rounded, JcfColors.skyPrimary,
          const Color(0xFFE3EEFF)),
      _ => (Icons.groups_rounded, const Color(0xFF7B5BD6),
          const Color(0xFFEAE3FA)),
    };

/// Upcoming Activities (design/25): programmes, live sessions and group
/// practices in one dated schedule with per-item reminders.
class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  String _filter = 'all';

  bool _matches(ActivityItem item) => switch (_filter) {
        'programme' => item.kind == 'programme',
        'live' => item.kind == 'live',
        'practice' => item.kind == 'practice',
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final feed = ref.watch(upcomingActivitiesProvider);

    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      appBar: AppBar(
        backgroundColor: JcfColors.skySurface,
        elevation: 0,
        foregroundColor: JcfColors.inkOnLight,
        title: Text(
          t.upcomingActivitiesTitle,
          style: const TextStyle(
            color: JcfColors.inkOnLight,
            fontFamily: JcfTypography.bodyFamily,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(upcomingActivitiesProvider),
            child: Text(t.genericError),
          ),
        ),
        data: (items) => _buildBody(context, t, items),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, AppLocalizations t, List<ActivityItem> items) {
    final locale = Localizations.localeOf(context).toString();
    final visible = items.where(_matches).toList();

    final today = DateUtils.dateOnly(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    // Design 25 groups by Monday-based week, matching the practice summary.
    final weekEnd = today.add(Duration(days: 7 - today.weekday));

    final todayItems = <ActivityItem>[];
    final tomorrowItems = <ActivityItem>[];
    final weekItems = <ActivityItem>[];
    final laterItems = <ActivityItem>[];
    for (final item in visible) {
      final day = DateUtils.dateOnly(item.startsAt);
      if (day == today) {
        todayItems.add(item);
      } else if (day == tomorrow) {
        tomorrowItems.add(item);
      } else if (!day.isAfter(weekEnd)) {
        weekItems.add(item);
      } else {
        laterItems.add(item);
      }
    }

    final dateFmt = DateFormat('EEE, d MMM yyyy', locale);
    final rangeFmt = DateFormat('d MMM', locale);
    final weekStart = weekEnd.subtract(const Duration(days: 6));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Text(
          t.upcomingActivitiesTagline,
          style: const TextStyle(
            color: _sub,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 14),
        _FilterRow(
          value: _filter,
          onChanged: (v) => setState(() => _filter = v),
        ),
        if (visible.isEmpty) ...[
          const SizedBox(height: 60),
          const Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFFE3EEFF),
              child: Icon(Icons.event_available_rounded,
                  size: 40, color: JcfColors.skyPrimary),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              t.noUpcoming,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _sub,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 15,
              ),
            ),
          ),
        ],
        if (todayItems.isNotEmpty)
          _Section(
              title: t.todaySection,
              dateLabel: dateFmt.format(today),
              items: todayItems),
        if (tomorrowItems.isNotEmpty)
          _Section(
              title: t.tomorrowSection,
              dateLabel: dateFmt.format(tomorrow),
              items: tomorrowItems),
        if (weekItems.isNotEmpty)
          _Section(
              title: t.thisWeekTitle,
              dateLabel:
                  '${rangeFmt.format(weekStart)} – ${rangeFmt.format(weekEnd)}',
              items: weekItems),
        if (laterItems.isNotEmpty)
          _Section(title: t.laterSection, dateLabel: '', items: laterItems),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final options = [
      ('all', t.filterAll),
      ('programme', t.filterProgrammes),
      ('live', t.filterLive),
      ('practice', t.filterPractice),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          for (final (key, label) in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(key),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: value == key ? JcfColors.skyPrimary : null,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          value == key ? Colors.white : JcfColors.inkOnLight,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 13.5,
                      fontWeight:
                          value == key ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(
      {required this.title, required this.dateLabel, required this.items});

  final String title;
  final String dateLabel;
  final List<ActivityItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              dateLabel,
              style: const TextStyle(
                color: _sub,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in items) ...[
          _ActivityCard(item: item),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ActivityCard extends ConsumerWidget {
  const _ActivityCard({required this.item});

  final ActivityItem item;

  (String, Color, Color) _audienceLook(AppLocalizations t) =>
      switch (item.audience) {
        'members' => (t.audienceMembers, const Color(0xFF7B5BD6),
            const Color(0xFFEAE3FA)),
        'students' => (t.audienceStudents, const Color(0xFFF08A24),
            const Color(0xFFFDEED9)),
        _ => (t.audiencePublic, JcfColors.skyPrimary,
            const Color(0xFFE3EEFF)),
      };

  String _whenLabel(BuildContext context, AppLocalizations t) {
    final locale = Localizations.localeOf(context).toString();
    final today = DateUtils.dateOnly(DateTime.now());
    final day = DateUtils.dateOnly(item.startsAt);
    final sameOrNextDay =
        day == today || day == today.add(const Duration(days: 1));
    final parts = <String>[
      if (!sameOrNextDay) DateFormat('EEE, d MMM', locale).format(item.startsAt),
      if (!item.allDay) DateFormat.jm(locale).format(item.startsAt),
      item.venue.isEmpty ? t.onlineLabel : item.venue,
    ];
    return parts.join('  ·  ');
  }

  Future<void> _toggleReminder(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (!ref.read(isLoggedInProvider)) {
      messenger.showSnackBar(SnackBar(content: Text(t.signInForReminders)));
      return;
    }
    try {
      final on =
          await ref.read(activitiesRepositoryProvider).toggleReminder(item);
      ref.invalidate(upcomingActivitiesProvider);
      messenger.showSnackBar(
          SnackBar(content: Text(on ? t.reminderOnSnack : t.reminderOffSnack)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.genericError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final (icon, tint, bg) = _kindLook(item.kind);
    final (audienceLabel, audienceTint, audienceBg) = _audienceLook(t);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: item.programSlug == null
            ? null
            : () => context.push('/programs/${item.programSlug}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: tint, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: JcfColors.inkOnLight,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (item.liveSoon)
                          Container(
                            margin: const EdgeInsetsDirectional.only(start: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE25563),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              t.liveSoonBadge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _whenLabel(context, t),
                      style: const TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _sub,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: audienceBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                audienceLabel,
                                style: TextStyle(
                                  color: audienceTint,
                                  fontFamily: JcfTypography.bodyFamily,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => _toggleReminder(context, ref),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: item.reminderSet
                                ? JcfColors.skyPrimary
                                : const Color(0xFFE3EEFF),
                            child: Icon(
                              item.reminderSet
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_none_rounded,
                              size: 21,
                              color: item.reminderSet
                                  ? Colors.white
                                  : JcfColors.skyPrimary,
                            ),
                          ),
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
    );
  }
}
