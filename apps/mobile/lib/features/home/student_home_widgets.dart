import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../core/brand.dart';
import '../../l10n/app_localizations.dart';
import 'member_home_widgets.dart' show MemberImage;
import 'student_home_repository.dart';

const _sub = Color(0xFF667085);
const _ink = Color(0xFF172033);
const _navy = Color(0xFF102454);
const _gold = Color(0xFFE9A33A);
const _green = Color(0xFF53A66F);
const _red = Color(0xFFD92D20);
const _amber = Color(0xFFF79009);

const _assetRoot = 'assets/images/student_home';

/// Header: logo, greeting, student badge, search, notifications, avatar.
class StudentHomeHeader extends StatelessWidget {
  const StudentHomeHeader(
      {super.key, required this.summary, required this.unreadCount});

  final StudentSummary summary;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final name = summary.displayName;
    final hour = DateTime.now().hour;
    final greeting = name == null
        ? t.welcomeBackGeneric
        : hour < 12
            ? t.greetingMorning(name)
            : hour < 18
                ? t.greetingAfternoon(name)
                : t.greetingEvening(name);

    return Row(
      children: [
        const JcfLogo(size: 44),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ink,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  t.studentChipLabel,
                  style: const TextStyle(
                    color: JcfColors.skyPrimary,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        _IconAction(
          icon: Icons.search_rounded,
          label: t.searchTitle,
          onTap: () => context.push('/search'),
        ),
        _IconAction(
          icon: Icons.notifications_none_rounded,
          label: t.notificationsTitle,
          badge: unreadCount,
          onTap: () => context.push('/notifications'),
        ),
        Semantics(
          button: true,
          label: t.profileTitle,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.push('/profile'),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: JcfColors.skyPrimary,
                  child: Text(
                    (name ?? '•').characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: JcfTypography.bodyFamily,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction(
      {required this.icon, required this.label, required this.onTap,
      this.badge = 0});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      value: badge > 0 ? '$badge' : null,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: _ink, size: 24),
              if (badge > 0)
                PositionedDirectional(
                  top: 10,
                  end: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    constraints: const BoxConstraints(minWidth: 16),
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
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

/// Enrolled-programme hero with progress.
class StudentProgramHero extends StatelessWidget {
  const StudentProgramHero({
    super.key,
    required this.enrolment,
    required this.onContinue,
    required this.showAllPrograms,
    required this.onViewAll,
  });

  final ProgramEnrolment enrolment;
  final VoidCallback onContinue;
  final bool showAllPrograms;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final percent = enrolment.clampedPercent;
    final meta = [enrolment.cohort, enrolment.intake]
        .where((s) => s.isNotEmpty)
        .join('  ·  ');

    return Semantics(
      label: '${enrolment.programTitle}. '
          '${t.programProgressSemantics(percent)}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: MemberImage(
                url: enrolment.imageUrl,
                asset: '$_assetRoot/student_home_program_hero.webp',
                width: MediaQuery.sizeOf(context).width,
                height: 220,
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: [Color(0xF2102454), Color(0xAA102454),
                      Color(0x33102454)],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.myProgramEyebrow,
                    style: const TextStyle(
                      color: Color(0xFFB9C9F5),
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    enrolment.programTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 20,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      meta,
                      style: const TextStyle(
                        color: Color(0xFFD7E2F8),
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                  if (enrolment.currentModuleTitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      enrolment.currentModuleTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            minHeight: 7,
                            backgroundColor: Colors.white24,
                            valueColor:
                                const AlwaysStoppedAnimation(_green),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: onContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: JcfColors.skyPrimary,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: JcfTypography.bodyFamily,
                          ),
                        ),
                        child: Text(t.continueProgram),
                      ),
                      if (showAllPrograms)
                        TextButton(
                          onPressed: onViewAll,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                            textStyle: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              fontFamily: JcfTypography.bodyFamily,
                            ),
                          ),
                          child: Text(t.viewAllPrograms),
                        ),
                    ],
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

/// Shared card shape for Continue Course and Assigned Practice.
class StudentTaskCard extends StatelessWidget {
  const StudentTaskCard({
    super.key,
    required this.imageUrl,
    required this.asset,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.tint,
    required this.onTap,
    this.percent,
    this.meta,
    this.statusLabel,
    this.statusColor,
    this.statusIcon,
  });

  final String imageUrl;
  final String asset;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String cta;
  final Color tint;
  final VoidCallback onTap;
  final int? percent;
  final String? meta;
  final String? statusLabel;
  final Color? statusColor;
  final IconData? statusIcon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: [title, subtitle, ?statusLabel,
        if (percent != null) '$percent%'].join('. '),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18)),
                    child: MemberImage(
                      url: imageUrl,
                      asset: asset,
                      width: double.infinity,
                      height: 92,
                    ),
                  ),
                  // Status uses an icon and words, never colour alone.
                  if (statusLabel != null)
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor ?? _sub,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (statusIcon != null) ...[
                              Icon(statusIcon, size: 11, color: Colors.white),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              statusLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow.toUpperCase(),
                      style: TextStyle(
                        color: tint,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _sub,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                    if (percent != null) ...[
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent! / 100,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFEAF2FF),
                          valueColor: AlwaysStoppedAnimation(tint),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ] else
                      const SizedBox(height: 8),
                    Row(
                      children: [
                        if (meta != null)
                          Expanded(
                            child: Text(
                              meta!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _sub,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 11,
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        if (percent != null)
                          Text(
                            '$percent%',
                            style: TextStyle(
                              color: tint,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: tint,
                          foregroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          textStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: JcfTypography.bodyFamily,
                          ),
                        ),
                        child: Text(cta,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
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

/// Live class card. Status is recomputed from the server's times.
class StudentLiveClassCard extends StatelessWidget {
  const StudentLiveClassCard({
    super.key,
    required this.liveClass,
    required this.onTap,
    required this.onReminder,
  });

  final LiveClass liveClass;
  final VoidCallback onTap;
  final VoidCallback onReminder;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final status = liveClass.status(now);
    final (label, color, icon) = switch (status) {
      'live' => (t.statusLive, _red, Icons.sensors_rounded),
      'starting_soon' => (t.statusStartingSoon, _amber, Icons.schedule_rounded),
      'replay' => (t.statusReplay, JcfColors.skyPrimary, Icons.replay_rounded),
      'missed' => (t.statusMissed, _sub, Icons.event_busy_rounded),
      'cancelled' => (t.statusCancelled, _sub, Icons.cancel_rounded),
      _ => (t.statusUpcoming, JcfColors.skyPrimary, Icons.event_rounded),
    };
    final cta = switch (status) {
      'live' => liveClass.canJoin(now) ? t.joinClass : t.viewDetails,
      'replay' => t.watchReplay,
      'missed' => t.viewClassSummary,
      'cancelled' => t.viewUpdate,
      _ => t.viewDetails,
    };
    final when = '${DateFormat('EEE, d MMM', locale).format(liveClass.startsAt)}'
        ' · ${DateFormat.jm(locale).format(liveClass.startsAt)}';
    final meta = [
      when,
      if (liveClass.facilitator.isNotEmpty) liveClass.facilitator,
      liveClass.venue.isEmpty ? t.onlineLabel : liveClass.venue,
    ].join('  ·  ');

    return Semantics(
      button: true,
      label: '$label. ${liveClass.title}. $meta',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: _navy,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned.fill(
                  child: MemberImage(
                    url: liveClass.imageUrl,
                    asset: '$_assetRoot/student_home_live_class.webp',
                    width: MediaQuery.sizeOf(context).width,
                    height: 196,
                  ),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xF2102454), Color(0x88102454),
                          Colors.transparent],
                        stops: [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 12, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(
                                  label.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: JcfTypography.bodyFamily,
                                    fontSize: 10,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Semantics(
                            button: true,
                            label: t.practiceReminders,
                            toggled: liveClass.reminderEnabled,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: onReminder,
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: Center(
                                  child: CircleAvatar(
                                    radius: 17,
                                    backgroundColor: liveClass.reminderEnabled
                                        ? Colors.white
                                        : Colors.white24,
                                    child: Icon(
                                      liveClass.reminderEnabled
                                          ? Icons.notifications_active_rounded
                                          : Icons.notifications_none_rounded,
                                      size: 18,
                                      color: liveClass.reminderEnabled
                                          ? JcfColors.skyPrimary
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      Text(
                        liveClass.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 17,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        meta,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFD7E2F8),
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: JcfColors.skyPrimary,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          textStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: JcfTypography.bodyFamily,
                          ),
                        ),
                        child: Text(cta),
                      ),
                    ],
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

/// Compact progress statistics — a summary, not a dashboard.
class StudentProgressSummary extends StatelessWidget {
  const StudentProgressSummary({super.key, required this.progress});

  final ProgressSummary progress;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final percent = progress.clampedPercent;

    return Semantics(
      label: t.programProgressSemantics(percent),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: CircularProgressIndicator(
                      value: percent / 100,
                      strokeWidth: 7,
                      backgroundColor: const Color(0xFFEAF2FF),
                      valueColor: const AlwaysStoppedAnimation(_green),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: _ink,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Stat(
                    icon: Icons.menu_book_rounded,
                    label: t.lessonsCompleted(
                        progress.completedLessons, progress.totalLessons),
                  ),
                  const SizedBox(height: 6),
                  _Stat(
                    icon: Icons.self_improvement_rounded,
                    label: t.practicesCompleted(progress.completedPractices,
                        progress.requiredPractices),
                  ),
                  const SizedBox(height: 6),
                  _Stat(
                    icon: Icons.local_fire_department_rounded,
                    label: t.dayStreak(progress.currentStreak),
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

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: JcfColors.skyPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Milestone card. The client never awards a milestone.
class StudentMilestoneCard extends StatelessWidget {
  const StudentMilestoneCard(
      {super.key, required this.milestone, required this.onTap});

  final StudentMilestone milestone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final achieved = milestone.status == 'achieved';
    final (label, color, icon) = achieved
        ? (t.milestoneAchieved, _gold, Icons.emoji_events_rounded)
        : milestone.status == 'locked'
            ? (t.milestoneLocked, _sub, Icons.lock_rounded)
            : (t.statusInProgress, JcfColors.skyPrimary,
                Icons.trending_up_rounded);

    return Semantics(
      button: true,
      label: '${milestone.title}. $label. '
          '${t.programProgressSemantics(milestone.clampedPercent)}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: _navy,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned.fill(
                  child: MemberImage(
                    url: milestone.imageUrl,
                    asset:
                        '$_assetRoot/student_home_progress_milestone.webp',
                    width: MediaQuery.sizeOf(context).width,
                    height: 176,
                  ),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.centerStart,
                        end: AlignmentDirectional.centerEnd,
                        colors: [Color(0xF2102454), Color(0x99102454),
                          Colors.transparent],
                        stops: [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              label.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 9.5,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      FractionallySizedBox(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: 0.75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              milestone.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 17,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (milestone.description.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                milestone.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFD7E2F8),
                                  fontFamily: JcfTypography.bodyFamily,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: milestone.clampedPercent / 100,
                                minHeight: 6,
                                backgroundColor: Colors.white24,
                                valueColor:
                                    AlwaysStoppedAnimation(achieved
                                        ? _gold
                                        : _green),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${milestone.clampedPercent}/'
                            '${milestone.requiredProgress}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: JcfColors.skyPrimary,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          textStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: JcfTypography.bodyFamily,
                          ),
                        ),
                        child: Text(t.viewProgress),
                      ),
                    ],
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

/// Mentor card, or the programme-support state when none is assigned.
class StudentMentorCard extends StatelessWidget {
  const StudentMentorCard({
    super.key,
    required this.mentor,
    required this.onMessage,
    required this.onView,
  });

  final StudentMentor? mentor;
  final VoidCallback onMessage;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final m = mentor;

    if (m == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFEAF2FF),
              child: Icon(Icons.support_agent_rounded,
                  color: JcfColors.skyPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t.noMentorAssigned,
                style: const TextStyle(
                  color: _sub,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final checkIn = m.nextCheckInAt;
    final meta = [
      if (m.availability.isNotEmpty) m.availability,
      if (checkIn != null)
        DateFormat('EEE, d MMM · HH:mm', locale).format(checkIn),
    ].join('  ·  ');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onView,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: MemberImage(
                  // The section artwork is only a backdrop; it is never
                  // presented as a photograph of this named mentor.
                  url: m.avatarUrl,
                  asset: '$_assetRoot/student_home_mentor_support.webp',
                  width: 76,
                  height: 76,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      m.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: JcfColors.skyPrimary,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _sub,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // Messaging appears only where the programme enables it.
                        if (m.messagingEnabled)
                          FilledButton(
                            onPressed: onMessage,
                            style: FilledButton.styleFrom(
                              backgroundColor: JcfColors.skyPrimary,
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                fontFamily: JcfTypography.bodyFamily,
                              ),
                            ),
                            child: Text(t.messageMentor),
                          ),
                        OutlinedButton(
                          onPressed: onView,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: JcfColors.skyPrimary,
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: JcfTypography.bodyFamily,
                            ),
                          ),
                          child: Text(t.viewMentor),
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

/// Priority updates: icon + words carry urgency, not colour alone.
class StudentUpdateTile extends StatelessWidget {
  const StudentUpdateTile(
      {super.key, required this.update, required this.onTap});

  final StudentUpdate update;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final (icon, tint) = switch (update.type) {
      'assignment' => (Icons.assignment_rounded, _amber),
      'schedule_change' => (Icons.event_repeat_rounded, JcfColors.skyPrimary),
      'mentor_notice' => (Icons.support_agent_rounded, _green),
      'administrative' => (Icons.info_rounded, _sub),
      _ => (Icons.campaign_rounded, JcfColors.skyPrimary),
    };
    final (priorityLabel, priorityColor) = switch (update.priority) {
      'urgent' => (t.priorityUrgent, _red),
      'important' => (t.priorityImportant, _amber),
      _ => (null, _sub),
    };
    final due = update.dueAt;
    final date = due != null
        ? t.dueLabel(DateFormat('d MMM', locale).format(due))
        : update.publishedAt == null
            ? ''
            : DateFormat('d MMM', locale).format(update.publishedAt!);

    return Semantics(
      button: true,
      label: [?priorityLabel, update.title, date].join('. '),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: tint.withValues(alpha: .12),
                  child: Icon(icon, size: 18, color: tint),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!update.read)
                            Container(
                              width: 8,
                              height: 8,
                              margin:
                                  const EdgeInsetsDirectional.only(end: 6),
                              decoration: const BoxDecoration(
                                color: JcfColors.skyPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              update.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _ink,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (priorityLabel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: priorityColor.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    update.priority == 'urgent'
                                        ? Icons.priority_high_rounded
                                        : Icons.flag_rounded,
                                    size: 11,
                                    color: priorityColor,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    priorityLabel,
                                    style: TextStyle(
                                      color: priorityColor,
                                      fontFamily: JcfTypography.bodyFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        update.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _sub,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                      if (date.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          date,
                          style: TextStyle(
                            color: due != null ? priorityColor : _sub,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 11,
                            fontWeight: due != null
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: _sub, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Quick actions. Identifiers map to known routes.
class StudentQuickActions extends StatelessWidget {
  const StudentQuickActions({super.key, required this.actions});

  final List<StudentQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    (IconData, String, VoidCallback)? resolve(String id) => switch (id) {
          'courses' => (
              Icons.video_library_rounded,
              t.myCourses,
              () => context.go('/lessons'),
            ),
          'schedule' => (
              Icons.calendar_month_rounded,
              t.scheduleLabel,
              () => context.push('/activities'),
            ),
          'assignments' => (
              Icons.assignment_rounded,
              t.assignmentsLabel,
              () => context.go('/practice'),
            ),
          'downloads' => (
              Icons.download_rounded,
              t.downloadsLabel,
              () => context.go('/more'),
            ),
          _ => null,
        };

    final resolved = [for (final a in actions) ?resolve(a.id)];
    if (resolved.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (var i = 0; i < resolved.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              button: true,
              label: resolved[i].$2,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: resolved[i].$3,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 76),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(resolved[i].$1,
                            color: JcfColors.skyPrimary, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          resolved[i].$2,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 11.5,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Restriction banner: paused, expired, completed or not enrolled.
class StudentRestrictionCard extends StatelessWidget {
  const StudentRestrictionCard({super.key, required this.restriction});

  final String restriction;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final (title, icon, color) = switch (restriction) {
      'paused' => (t.programPausedTitle, Icons.pause_circle_rounded, _amber),
      'expired' => (t.accessExpiredTitle, Icons.lock_clock_rounded, _red),
      'completed' => (t.milestoneAchieved, Icons.emoji_events_rounded, _gold),
      'suspended' => (t.accessExpiredTitle, Icons.block_rounded, _red),
      _ => (t.noProgramEnrolled, Icons.school_rounded, JcfColors.skyPrimary),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _ink,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton matching the final layout.
class StudentHomeSkeleton extends StatelessWidget {
  const StudentHomeSkeleton({super.key});

  Widget _block({double height = 16, double? width, double radius = 12}) =>
      Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFFE3EAF6),
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          children: [
            _block(height: 44, width: 44, radius: 22),
            const SizedBox(width: 10),
            Expanded(child: _block(height: 18)),
            const SizedBox(width: 10),
            _block(height: 36, width: 36, radius: 18),
          ],
        ),
        const SizedBox(height: 18),
        _block(height: 220, radius: 20),
        const SizedBox(height: 26),
        _block(height: 18, width: 170),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _block(height: 230, radius: 18)),
            const SizedBox(width: 12),
            Expanded(child: _block(height: 230, radius: 18)),
          ],
        ),
        const SizedBox(height: 26),
        _block(height: 18, width: 150),
        const SizedBox(height: 12),
        _block(height: 196, radius: 20),
        const SizedBox(height: 26),
        _block(height: 104, radius: 18),
      ],
    );
  }
}
