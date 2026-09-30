import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../home/member_home_widgets.dart' show MemberImage;
import 'activity_models.dart';

const _muted = Color(0xFF54689B);
const _hairline = Color(0xFFE3EAF7);

/// Packaged artwork for an activity, chosen by the server's `image_key`.
///
/// The server sends a key rather than a bundled path so new categories can
/// be styled without shipping an app update, and an unknown key falls back
/// to a neutral card instead of a broken image.
String activityAsset(String imageKey, String activityType) {
  const byKey = {
    'featured_banner': 'featured_banner',
    'guided_meditation': 'guided_meditation',
    'workshop': 'workshop',
    'retreat': 'retreat',
    'online_teaching': 'online_teaching',
  };
  const byType = {
    'meditation': 'guided_meditation',
    'workshop': 'workshop',
    'retreat': 'retreat',
    'teaching': 'online_teaching',
    'satsang': 'featured_banner',
    'community': 'featured_banner',
  };
  final name = byKey[imageKey] ?? byType[activityType] ?? 'featured_banner';
  return 'assets/images/upcoming_activities/upcoming_activities_$name.webp';
}

/// The localized label for an activity's format.
String formatLabel(AppLocalizations t, ActivityFormat format) =>
    switch (format) {
      ActivityFormat.online => t.activitiesFormatOnline,
      ActivityFormat.inPerson => t.activitiesFormatInPerson,
      ActivityFormat.hybrid => t.activitiesFormatHybrid,
    };

/// "Today" / "Tomorrow" / a written date, for a list section heading.
String dayHeading(AppLocalizations t, String locale, DateTime day,
    DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final difference = day.difference(today).inDays;
  if (difference == 0) return t.activitiesToday;
  if (difference == 1) return t.activitiesTomorrow;
  return DateFormat('EEEE, d MMMM', locale).format(day);
}

/// The time line under a title: a clock range, or "All day".
String timeLine(AppLocalizations t, String locale, Activity activity) {
  if (activity.allDay) return t.activitiesAllDay;
  final start = DateFormat.jm(locale).format(activity.startsAt);
  final end = DateFormat.jm(locale).format(activity.endsAt);
  return '$start – $end';
}

/// The small dated square at the head of a card.
class ActivityDateBlock extends StatelessWidget {
  const ActivityDateBlock({
    super.key,
    required this.date,
    this.dimmed = false,
  });

  final DateTime date;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final month = DateFormat('MMM', locale).format(date).toUpperCase();
    final colour = dimmed ? _muted : JcfColors.skyPrimary;
    return Container(
      width: 46,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: dimmed ? const Color(0xFFF1F3F8) : const Color(0xFFE8F0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            month,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colour,
            ),
          ),
          Text(
            DateFormat('d', locale).format(date),
            style: TextStyle(
              fontSize: 20,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: dimmed ? _muted : JcfColors.inkOnLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// A pill: type, format, live, cancelled, locked.
class ActivityBadge extends StatelessWidget {
  const ActivityBadge({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(icon == null ? 8 : 6, 3, 8, 3),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: foreground),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ],
        ),
      );
}

/// The badges a card carries, in the order they matter: a cancellation
/// first, because it changes what every other badge means.
List<Widget> activityBadges(AppLocalizations t, Activity activity) {
  final badges = <Widget>[];
  if (activity.cancelled) {
    badges.add(ActivityBadge(
      label: t.activitiesCancelled,
      foreground: const Color(0xFF9B1C1C),
      background: const Color(0xFFFDE8E8),
      icon: Icons.event_busy_rounded,
    ));
  } else if (activity.isLiveNow) {
    badges.add(ActivityBadge(
      label: t.statusLive,
      foreground: Colors.white,
      background: const Color(0xFFE02D3C),
      icon: Icons.sensors_rounded,
    ));
  } else if (activity.startingSoon) {
    badges.add(ActivityBadge(
      label: t.statusStartingSoon,
      foreground: const Color(0xFF8A4B00),
      background: const Color(0xFFFDEED9),
    ));
  }
  if (activity.activityTypeLabel.isNotEmpty) {
    badges.add(ActivityBadge(
      label: activity.activityTypeLabel,
      foreground: JcfColors.skyPrimary,
      background: const Color(0xFFE8F0FF),
    ));
  }
  badges.add(ActivityBadge(
    label: formatLabel(t, activity.format),
    foreground: _muted,
    background: const Color(0xFFF1F3F8),
    icon: activity.format == ActivityFormat.online
        ? Icons.videocam_rounded
        : Icons.place_rounded,
  ));
  if (!activity.access.allowed) {
    badges.add(ActivityBadge(
      label: activity.access.reason == 'students_only'
          ? t.activitiesStudentsOnly
          : t.activitiesMembersOnly,
      foreground: const Color(0xFF6B4A00),
      background: const Color(0xFFFBF0D5),
      icon: Icons.lock_rounded,
    ));
  }
  return badges;
}

/// What the registration button says and whether it can be pressed.
/// Derived from the server's state — never from the dates on the card.
({String label, bool enabled, bool destructive}) registrationCta(
    AppLocalizations t, String locale, Activity activity) {
  final registration = activity.registration;
  if (registration.mine == MyRegistration.registered) {
    return (
      label: t.activitiesCancelRegistration,
      enabled: !activity.cancelled,
      destructive: true
    );
  }
  if (registration.mine == MyRegistration.waitlisted) {
    return (
      label: t.activitiesCancelRegistration,
      enabled: !activity.cancelled,
      destructive: true
    );
  }
  return switch (registration.state) {
    RegistrationState.open => (
        label: t.activitiesRegister,
        enabled: true,
        destructive: false
      ),
    RegistrationState.waitlist => (
        label: t.activitiesJoinWaitlist,
        enabled: true,
        destructive: false
      ),
    RegistrationState.full => (
        label: t.activitiesRegistrationFull,
        enabled: false,
        destructive: false
      ),
    RegistrationState.closed => (
        label: t.activitiesRegistrationClosed,
        enabled: false,
        destructive: false
      ),
    RegistrationState.opensLater => (
        label: t.activitiesRegistrationOpensOn(
            registration.opensAt == null
                ? ''
                : DateFormat('d MMM', locale).format(registration.opensAt!)),
        enabled: false,
        destructive: false
      ),
    RegistrationState.external => (
        label: t.activitiesRegisterExternally,
        enabled: true,
        destructive: false
      ),
    RegistrationState.cancelled => (
        label: t.activitiesCancelled,
        enabled: false,
        destructive: false
      ),
    RegistrationState.notRequired => (
        label: '',
        enabled: false,
        destructive: false
      ),
  };
}

/// One row of the schedule.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.onOpen,
    required this.onReminder,
    required this.onSave,
    required this.onRegister,
  });

  final Activity activity;
  final VoidCallback onOpen;
  final VoidCallback onReminder;
  final VoidCallback onSave;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final cta = registrationCta(t, locale, activity);
    final showCta = activity.registration.required_ && cta.label.isNotEmpty;
    final dimmed = activity.cancelled;

    return Opacity(
      // A cancelled activity stays in place and greys out: removing it
      // would leave someone wondering whether they misremembered the day.
      opacity: dimmed ? 0.62 : 1,
      child: Semantics(
        button: true,
        label: _semanticLabel(t, locale),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: MemberImage(
                          url: activity.imageUrl,
                          asset: activityAsset(
                              activity.imageKey, activity.activityType),
                          width: 84,
                          height: 84,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _details(context, t, locale)),
                    ],
                  ),
                  if (activity.rescheduledNote.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _note(t.activitiesRescheduled,
                        activity.rescheduledNote),
                  ],
                  if (showCta) ...[
                    const SizedBox(height: 12),
                    _registrationRow(context, t, cta),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _details(
      BuildContext context, AppLocalizations t, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                activity.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: JcfColors.inkOnLight,
                ),
              ),
            ),
            // The bell sits outside the title's flex slot so a long title
            // can never run underneath it.
            _iconAction(
              context,
              icon: activity.reminderSet
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              active: activity.reminderSet,
              tooltip: t.remindMe,
              onPressed: onReminder,
            ),
            _iconAction(
              context,
              icon: activity.saved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              active: activity.saved,
              tooltip: t.saveForLater,
              onPressed: onSave,
            ),
          ],
        ),
        const SizedBox(height: 4),
        _metaRow(Icons.schedule_rounded, timeLine(t, locale, activity)),
        if (activity.locationLine.isNotEmpty)
          _metaRow(
              activity.format == ActivityFormat.online
                  ? Icons.videocam_rounded
                  : Icons.place_rounded,
              activity.locationLine),
        if (activity.facilitator != null)
          _metaRow(Icons.person_rounded,
              activity.facilitator!.displayName),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ...activityBadges(t, activity),
            if (!activity.fee.free)
              ActivityBadge(
                label: activity.fee.display,
                foreground: const Color(0xFF14663B),
                background: const Color(0xFFDDF3E4),
              )
            else if (activity.registration.required_)
              ActivityBadge(
                label: t.activitiesFree,
                foreground: const Color(0xFF14663B),
                background: const Color(0xFFDDF3E4),
              ),
          ],
        ),
      ],
    );
  }

  Widget _metaRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Icon(icon, size: 13, color: _muted),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
            ),
          ],
        ),
      );

  Widget _iconAction(
    BuildContext context, {
    required IconData icon,
    required bool active,
    required String tooltip,
    required VoidCallback onPressed,
  }) =>
      IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
        icon: Icon(
          icon,
          size: 19,
          color: active ? JcfColors.skyPrimary : _muted,
        ),
      );

  Widget _note(String title, String body) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFDEED9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$title • $body',
          style: const TextStyle(
              fontSize: 12, color: Color(0xFF8A4B00), height: 1.35),
        ),
      );

  Widget _registrationRow(
    BuildContext context,
    AppLocalizations t,
    ({String label, bool enabled, bool destructive}) cta,
  ) {
    final registration = activity.registration;
    final mine = registration.mine;
    return Row(
      children: [
        if (mine == MyRegistration.registered ||
            mine == MyRegistration.waitlisted)
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 16, color: Color(0xFF14663B)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    mine == MyRegistration.registered
                        ? t.activitiesRegistered
                        : t.activitiesWaitlisted,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF14663B)),
                  ),
                ),
              ],
            ),
          )
        else if (registration.nearlyFull)
          Expanded(
            child: Text(
              t.activitiesSeatsLeft(registration.seatsLeft!),
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A4B00)),
            ),
          )
        else
          const Spacer(),
        const SizedBox(width: 8),
        TextButton(
          onPressed: cta.enabled ? onRegister : null,
          style: TextButton.styleFrom(
            backgroundColor: cta.destructive
                ? const Color(0xFFF1F3F8)
                : JcfColors.skyPrimary,
            foregroundColor:
                cta.destructive ? _muted : Colors.white,
            disabledBackgroundColor: const Color(0xFFF1F3F8),
            disabledForegroundColor: _muted,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999)),
            textStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700),
          ),
          child: Text(cta.label),
        ),
      ],
    );
  }

  String _semanticLabel(AppLocalizations t, String locale) {
    final parts = <String>[
      activity.title,
      DateFormat('EEEE d MMMM', locale).format(activity.startsAt),
      timeLine(t, locale, activity),
      if (activity.locationLine.isNotEmpty) activity.locationLine,
      formatLabel(t, activity.format),
      if (activity.cancelled) t.activitiesCancelled,
      if (!activity.access.allowed)
        activity.access.reason == 'students_only'
            ? t.activitiesStudentsOnly
            : t.activitiesMembersOnly,
    ];
    return parts.join('. ');
  }
}

/// The banner above the list. The server picks it; the app only draws it.
class FeaturedActivityCard extends StatelessWidget {
  const FeaturedActivityCard({
    super.key,
    required this.activity,
    required this.onOpen,
  });

  final Activity activity;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final when = activity.allDay
        ? DateFormat('EEE, d MMM', locale).format(activity.startsAt)
        : '${DateFormat('EEE, d MMM', locale).format(activity.startsAt)}'
            ' • ${DateFormat.jm(locale).format(activity.startsAt)}';

    return Semantics(
      button: true,
      label: '${t.activitiesFeaturedEyebrow}. ${activity.title}. $when',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: JcfColors.cosmicDeep,
          child: InkWell(
            onTap: onOpen,
            child: SizedBox(
              height: 186,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MemberImage(
                    url: activity.imageUrl,
                    asset: activityAsset(
                        activity.imageKey, activity.activityType),
                    width: double.infinity,
                    height: 186,
                  ),
                  // One gradient over the whole frame, so the artwork and
                  // the text read as a single card rather than a photo
                  // with a caption stuck underneath it.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          Color(0x59060E4A),
                          Color(0xE6060E4A),
                        ],
                        stops: [0.15, 0.52, 1],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ActivityBadge(
                          label: t.activitiesFeaturedEyebrow,
                          foreground: JcfColors.cosmicDeep,
                          background: JcfColors.gold,
                          icon: Icons.star_rounded,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activity.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 19,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.featuredBlurb.isNotEmpty
                              ? activity.featuredBlurb
                              : '$when • ${activity.locationLine}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFFD9E3FF),
                          ),
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

/// A week of day pills. The first weekday follows the locale, so a Sunday
/// column never appears first for a reader whose week starts on Monday.
class WeekSelector extends StatelessWidget {
  const WeekSelector({
    super.key,
    required this.weekStart,
    required this.selected,
    required this.today,
    required this.onSelect,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final DateTime weekStart;
  final DateTime? selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  /// The start of the week containing [day], honouring the locale's own
  /// first weekday.
  static DateTime startOfWeek(BuildContext context, DateTime day) {
    final first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    // DateTime.weekday is 1..7 with Monday = 1; firstDayOfWeekIndex is
    // 0..6 with Sunday = 0.
    final weekdayIndex = day.weekday % 7;
    final delta = (weekdayIndex - first + 7) % 7;
    return DateTime(day.year, day.month, day.day)
        .subtract(Duration(days: delta));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final days = [
      for (var i = 0; i < 7; i++) weekStart.add(Duration(days: i))
    ];
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onPreviousWeek,
              tooltip: t.activitiesPreviousWeek,
              icon: const Icon(Icons.chevron_left_rounded, size: 22),
              color: _muted,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy', locale).format(days[3]),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: JcfColors.inkOnLight,
                ),
              ),
            ),
            IconButton(
              onPressed: onNextWeek,
              tooltip: t.activitiesNextWeek,
              icon: const Icon(Icons.chevron_right_rounded, size: 22),
              color: _muted,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            for (final day in days)
              Expanded(
                child: _DayPill(
                  day: day,
                  locale: locale,
                  isSelected: selected != null && _sameDay(day, selected!),
                  isToday: _sameDay(day, today),
                  isPast: day.isBefore(today),
                  onTap: () => onSelect(day),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.day,
    required this.locale,
    required this.isSelected,
    required this.isToday,
    required this.isPast,
    required this.onTap,
  });

  final DateTime day;
  final String locale;
  final bool isSelected;
  final bool isToday;
  final bool isPast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final letter = DateFormat('EEE', locale).format(day);
    final number = DateFormat('d', locale).format(day);
    final foreground = isSelected
        ? Colors.white
        : isPast
            ? const Color(0xFFA9B4CC)
            : JcfColors.inkOnLight;
    return Semantics(
      selected: isSelected,
      button: true,
      label: DateFormat('EEEE d MMMM', locale).format(day),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Text(
                letter,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? JcfColors.skyPrimary : _muted,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? JcfColors.skyPrimary
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday && !isSelected
                      ? Border.all(color: JcfColors.skyPrimary, width: 1.4)
                      : null,
                ),
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A month grid with a density dot under each day that has something on it.
class ActivityCalendarGrid extends StatelessWidget {
  const ActivityCalendarGrid({
    super.key,
    required this.month,
    required this.days,
    required this.selected,
    required this.today,
    required this.onSelect,
  });

  final DateTime month;
  final List<CalendarDay> days;
  final DateTime? selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final leading = (firstOfMonth.weekday % 7 - first + 7) % 7;
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;
    final byDay = {
      for (final day in days)
        DateTime(day.date.year, day.date.month, day.date.day): day
    };
    final cells = <Widget>[];

    for (var i = 0; i < 7; i++) {
      final sample = DateTime(2024, 1, 7 + ((first + i) % 7));
      cells.add(Center(
        child: Text(
          DateFormat('EEE', locale).format(sample),
          style: const TextStyle(
              fontSize: 10.5, fontWeight: FontWeight.w600, color: _muted),
        ),
      ));
    }
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      cells.add(_CalendarCell(
        date: date,
        locale: locale,
        entry: byDay[date],
        isSelected: selected != null &&
            WeekSelector._sameDay(date, selected!),
        isToday: WeekSelector._sameDay(date, today),
        onTap: () => onSelect(date),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.82,
      children: cells,
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.date,
    required this.locale,
    required this.entry,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final String locale;
  final CalendarDay? entry;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = entry?.count ?? 0;
    return Semantics(
      selected: isSelected,
      button: true,
      label: DateFormat('EEEE d MMMM', locale).format(date),
      value: count == 0 ? null : '$count',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    isSelected ? JcfColors.skyPrimary : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday && !isSelected
                    ? Border.all(color: JcfColors.skyPrimary, width: 1.4)
                    : null,
              ),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : count > 0
                          ? JcfColors.inkOnLight
                          : _muted,
                ),
              ),
            ),
            const SizedBox(height: 3),
            // Up to three dots, so a busy day reads as busy without
            // printing a number nobody needs.
            SizedBox(
              height: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < count.clamp(0, 3); i++)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: entry?.hasLive == true && i == 0
                            ? const Color(0xFFE02D3C)
                            : JcfColors.skyPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The grey blocks shown while the first page loads.
class ActivitySkeleton extends StatelessWidget {
  const ActivitySkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 132,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _hairline),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _block(84, 84, radius: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(double.infinity, 14),
                  const SizedBox(height: 8),
                  _block(140, 11),
                  const SizedBox(height: 6),
                  _block(110, 11),
                  const SizedBox(height: 12),
                  _block(90, 18, radius: 999),
                ],
              ),
            ),
          ],
        ),
      );

  static Widget _block(double width, double height, {double radius = 6}) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFEDF1F8),
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

/// An empty or failed list, with one thing to do about it.
class ActivityPlaceholder extends StatelessWidget {
  const ActivityPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F0FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: JcfColors.skyPrimary),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: JcfColors.inkOnLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, height: 1.45, color: _muted),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: JcfColors.skyPrimary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 12),
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
