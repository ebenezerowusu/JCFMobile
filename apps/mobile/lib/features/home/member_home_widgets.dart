import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../core/brand.dart';
import '../../l10n/app_localizations.dart';
import 'member_home_repository.dart';

const _sub = Color(0xFF667085);
const _ink = Color(0xFF172033);
const _navy = Color(0xFF102454);
const _gold = Color(0xFFE9A33A);
const _green = Color(0xFF53A66F);
const _liveRed = Color(0xFFD92D20);

/// Remote image first, packaged asset as the intentional fallback, neutral
/// placeholder last (member home spec).
class MemberImage extends StatelessWidget {
  const MemberImage({
    super.key,
    required this.url,
    required this.asset,
    required this.width,
    required this.height,
    this.semanticLabel,
  });

  final String url;
  final String asset;
  final double width;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    // A card may pass double.infinity; fall back to the viewport width so the
    // decode hint stays finite and positive.
    final logical = width.isFinite && width > 0
        ? width
        : MediaQuery.sizeOf(context).width;
    final cacheWidth = logical > 0 ? (logical * dpr).round() : null;
    final fallback = Image.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      excludeFromSemantics: semanticLabel == null,
      semanticLabel: semanticLabel,
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        color: const Color(0xFFEAF2FF),
      ),
    );
    if (url.isEmpty) return fallback;
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      excludeFromSemantics: semanticLabel == null,
      semanticLabel: semanticLabel,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

/// Member header: logo, time-aware greeting, membership label, actions.
class MemberHomeHeader extends StatelessWidget {
  const MemberHomeHeader({
    super.key,
    required this.summary,
    required this.unreadCount,
  });

  final MemberSummary summary;
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  summary.membershipLabel,
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
        _HeaderAction(
          icon: Icons.search_rounded,
          label: t.searchTitle,
          onTap: () => context.push('/search'),
        ),
        _HeaderAction(
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

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });

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
              // Badge floats over the icon so its alignment never shifts.
              if (badge > 0)
                PositionedDirectional(
                  top: 10,
                  end: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    constraints: const BoxConstraints(minWidth: 16),
                    decoration: BoxDecoration(
                      color: _liveRed,
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

/// Personalized welcome hero.
class MemberWelcomeHero extends StatelessWidget {
  const MemberWelcomeHero({
    super.key,
    required this.welcome,
    required this.name,
    required this.onTap,
  });

  final WelcomeContent welcome;
  final String? name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Positioned.fill(
            child: MemberImage(
              url: welcome.imageUrl,
              asset: 'assets/images/member_home/member_home_welcome_hero.webp',
              width: MediaQuery.sizeOf(context).width,
              height: 196,
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: [
                    Color(0xF2102454),
                    Color(0x99102454),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.55, 1.0],
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
                  welcome.eyebrow,
                  style: const TextStyle(
                    color: Color(0xFFB9C9F5),
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 0.72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        welcome.title(name),
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
                      const SizedBox(height: 5),
                      Text(
                        welcome.message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFD7E2F8),
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: JcfColors.skyPrimary,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: JcfTypography.bodyFamily,
                    ),
                  ),
                  child: Text(welcome.actionLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Resume card shared by Continue Learning and Continue Practice.
class ResumeCard extends StatelessWidget {
  const ResumeCard({
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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: percent == null
          ? '$title. $subtitle'
          : '$title. $subtitle. $percent%',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: MemberImage(
                  url: imageUrl,
                  asset: asset,
                  width: double.infinity,
                  height: 92,
                ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _sub,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 12,
                      ),
                    ),
                    // Indeterminate progress shows no bar rather than a
                    // misleading empty one.
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
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: JcfTypography.bodyFamily,
                          ),
                        ),
                        child: Text(
                          cta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

/// Member-exclusive featured content.
class MemberExclusiveCard extends StatelessWidget {
  const MemberExclusiveCard({
    super.key,
    required this.content,
    required this.onTap,
  });

  final FeaturedContent content;
  final VoidCallback onTap;

  String _cta(AppLocalizations t) => switch (content.contentType) {
    'audio' => t.listenNow,
    'article' || 'written' => t.readNow,
    'course' => t.startCourse,
    'series' => t.exploreSeries,
    _ => t.watchNow,
  };

  String _typeLabel(AppLocalizations t) => switch (content.contentType) {
    'audio' => t.kindAudio,
    'article' || 'written' => t.kindAnnouncement,
    'series' => t.kindProgramme,
    _ => t.kindVideo,
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final seconds = content.durationSeconds;
    final duration = seconds == null || seconds == 0
        ? (content.readingTimeMinutes == null
              ? ''
              : t.remainingTime(content.readingTimeMinutes!))
        : '${seconds ~/ 60} min';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: _navy,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned.fill(
                child: MemberImage(
                  url: content.imageUrl,
                  asset:
                      'assets/images/member_home/member_home_exclusive_teaching.webp',
                  width: MediaQuery.sizeOf(context).width,
                  height: 200,
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xF2102454),
                        Color(0x88102454),
                        Colors.transparent,
                      ],
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
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.memberExclusive,
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
                    const SizedBox(height: 60),
                    Text(
                      _typeLabel(t).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFB9C9F5),
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 18,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        content.speaker,
                        duration,
                      ].where((s) => s.isNotEmpty).join('  ·  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD7E2F8),
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: onTap,
                      icon: Icon(
                        content.accessGranted
                            ? Icons.play_arrow_rounded
                            : Icons.lock_rounded,
                        size: 17,
                      ),
                      label: Text(_cta(t)),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: JcfColors.skyPrimary,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          fontFamily: JcfTypography.bodyFamily,
                        ),
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

/// Member Live & Upcoming card with reminder control.
class MemberLiveUpcomingCard extends ConsumerWidget {
  const MemberLiveUpcomingCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onReminder,
  });

  final MemberEvent event;
  final VoidCallback onTap;
  final VoidCallback onReminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final status = event.status(DateTime.now());
    final (label, color) = switch (status) {
      'live' => (t.statusLive, _liveRed),
      'starting_soon' => (t.statusStartingSoon, _gold),
      'replay' => (t.watchReplay, JcfColors.skyPrimary),
      _ => (t.statusUpcoming, JcfColors.skyPrimary),
    };
    final cta = switch (status) {
      'live' => t.joinLive,
      'replay' => t.watchReplay,
      _ => t.viewDetails,
    };
    final when = event.allDay
        ? DateFormat('EEE, d MMM', locale).format(event.startsAt)
        : '${DateFormat('EEE, d MMM', locale).format(event.startsAt)} · '
              '${DateFormat.jm(locale).format(event.startsAt)}';
    final meta = [
      when,
      if (event.facilitator.isNotEmpty) event.facilitator,
      event.format.isEmpty ? t.onlineLabel : event.format,
    ].join('  ·  ');

    return Semantics(
      button: true,
      label: '$label. ${event.title}. $meta',
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
                    url: event.imageUrl,
                    asset:
                        'assets/images/member_home/member_home_live_upcoming.webp',
                    width: MediaQuery.sizeOf(context).width,
                    height: 188,
                  ),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xF2102454),
                          Color(0x77102454),
                          Colors.transparent,
                        ],
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
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (status == 'live') ...[
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
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
                            toggled: event.reminderEnabled,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: onReminder,
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: Center(
                                  child: CircleAvatar(
                                    radius: 17,
                                    backgroundColor: event.reminderEnabled
                                        ? Colors.white
                                        : Colors.white24,
                                    child: Icon(
                                      event.reminderEnabled
                                          ? Icons.notifications_active_rounded
                                          : Icons.notifications_none_rounded,
                                      size: 18,
                                      color: event.reminderEnabled
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
                      const SizedBox(height: 34),
                      Text(
                        event.title,
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
                            borderRadius: BorderRadius.circular(20),
                          ),
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

/// Quick actions row. Identifiers are stable; the app owns icons and routes.
class MemberQuickActions extends StatelessWidget {
  const MemberQuickActions({super.key, required this.actions});

  final List<QuickActionItem> actions;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    (IconData, String, VoidCallback)? resolve(String id) => switch (id) {
      'my_library' => (
        Icons.video_library_rounded,
        t.myLibrary,
        () => context.go('/lessons'),
      ),
      'my_programs' => (
        Icons.workspaces_rounded,
        t.myPrograms,
        () => context.go('/programs'),
      ),
      'saved' => (
        Icons.bookmark_rounded,
        t.savedLabel,
        () => context.go('/more'),
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
        for (final (icon, label, onTap) in resolved) ...[
          Expanded(
            child: Semantics(
              button: true,
              label: label,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onTap,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 76),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 12,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: JcfColors.skyPrimary, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          label,
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
          if (resolved.last.$2 != label) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

/// Community announcement card.
class CommunityAnnouncementCard extends StatelessWidget {
  const CommunityAnnouncementCard({
    super.key,
    required this.announcement,
    required this.onTap,
  });

  final CommunityAnnouncement announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final published = announcement.publishedAt;
    final date = published == null
        ? ''
        : DateUtils.isSameDay(published, DateTime.now())
        ? t.todaySection
        : DateFormat('d MMM', locale).format(published);

    return Semantics(
      button: true,
      label: '${announcement.category}. ${announcement.title}',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: MemberImage(
                    url: announcement.imageUrl,
                    asset:
                        'assets/images/member_home/member_home_community_announcement.webp',
                    width: 84,
                    height: 84,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              announcement.category.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _green,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 10,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            date,
                            style: const TextStyle(
                              color: _sub,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!announcement.read)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsetsDirectional.only(
                                end: 6,
                                top: 5,
                              ),
                              decoration: const BoxDecoration(
                                color: JcfColors.skyPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              announcement.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _ink,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 15,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        announcement.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _sub,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.readUpdate,
                        style: const TextStyle(
                          color: JcfColors.skyPrimary,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
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
    );
  }
}

/// Skeleton matching the final card shapes (no full-page spinner).
class MemberHomeSkeleton extends StatelessWidget {
  const MemberHomeSkeleton({super.key});

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            _block(height: 196, radius: 20),
            const SizedBox(height: 24),
            _block(height: 18, width: 180),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _block(height: 210, radius: 18)),
                const SizedBox(width: 12),
                Expanded(child: _block(height: 210, radius: 18)),
              ],
            ),
            const SizedBox(height: 24),
            _block(height: 18, width: 140),
            const SizedBox(height: 12),
            _block(height: 200, radius: 20),
          ],
        ),
      ],
    );
  }
}
