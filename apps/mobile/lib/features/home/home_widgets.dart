import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcf_models/jcf_models.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../core/brand.dart';
import '../activities/activities_repository.dart';
import '../inspiration/inspiration_detail_screen.dart';
import '../inspiration/inspiration_repository.dart';

const _sub = Color(0xFF54689B);
const _muted = Color(0xFF9AA7C7);

/// Guest header: logo + wordmark (design/19).
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.onSearch, this.onBell});

  final VoidCallback? onSearch;
  final VoidCallback? onBell;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        const JcfLogo(size: 52),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'JAN COSMIC\nFOUNDATION',
                style: TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 16,
                  height: 1.12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                t.headerTagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _sub,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (onSearch != null) _HeaderIconButton(
            icon: Icons.search_rounded, onTap: onSearch!),
        if (onBell != null) ...[
          const SizedBox(width: 8),
          _HeaderIconButton(
              icon: Icons.notifications_none_rounded, onTap: onBell!),
        ],
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(23),
      onTap: onTap,
      child: CircleAvatar(
        radius: 21,
        backgroundColor: const Color(0xFFE3EEFF),
        child: Icon(icon, color: JcfColors.inkOnLight, size: 22),
      ),
    );
  }
}

/// Member/student header: avatar + role chip + bell (designs 20/21).
class MemberHeader extends StatelessWidget {
  const MemberHeader(
      {super.key, required this.member, required this.chip,
      this.studentStyle = false});

  final Member member;
  final String chip;
  final bool studentStyle;

  @override
  Widget build(BuildContext context) {
    final initial =
        member.fullName.isEmpty ? '•' : member.fullName[0].toUpperCase();
    return Row(
      children: [
        const JcfLogo(size: 48),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE3EEFF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(studentStyle ? Icons.school_rounded : Icons.person_rounded,
                  size: 17, color: JcfColors.skyPrimary),
              const SizedBox(width: 6),
              Text(
                chip,
                style: const TextStyle(
                  color: JcfColors.skyPrimary,
                  fontFamily: JcfTypography.bodyFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: const Icon(Icons.notifications_none_rounded,
              color: JcfColors.inkOnLight),
        ),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: JcfColors.skyPrimary,
            child: Text(initial,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}

class GreetingBlock extends StatelessWidget {
  const GreetingBlock(
      {super.key, required this.name, required this.tagline, this.headline});

  final String name;
  final String tagline;
  final String? headline;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    final greeting = headline ??
        (hour < 12
            ? t.greetingMorning(name)
            : hour < 18
                ? t.greetingAfternoon(name)
                : t.greetingEvening(name));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            color: JcfColors.inkOnLight,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 30,
            height: 1.1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tagline,
          style: const TextStyle(
            color: _sub,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

/// Daily Inspiration hero — live from /inspiration/today/, with a built-in
/// fallback quote when nothing is scheduled or the network is down.
class InspirationHero extends StatelessWidget {
  const InspirationHero({super.key, this.compact = false, this.inspiration});

  final bool compact;
  final Inspiration? inspiration;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final quote =
        inspiration == null ? t.defaultQuote : '“${inspiration!.quote}”';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E1D8F), Color(0xFF2E6BF0)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.dailyInspirationEyebrow,
            style: const TextStyle(
              color: Color(0xFFB9C9F5),
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            quote,
            style: TextStyle(
              color: Colors.white,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: compact ? 20 : 24,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (compact && inspiration != null) ...[
            const SizedBox(height: 8),
            Text(
              '— ${inspiration!.author}',
              style: const TextStyle(
                color: Color(0xFFB9C9F5),
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (!compact) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: inspiration == null
                  ? null
                  : () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => InspirationDetailScreen(
                            inspiration: inspiration!),
                      )),
              icon: const Icon(Icons.chevron_right),
              iconAlignment: IconAlignment.end,
              label: Text(t.readReflection),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: JcfColors.skyPrimary,
                disabledBackgroundColor: Colors.white70,
                disabledForegroundColor: JcfColors.skyPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: JcfTypography.bodyFamily,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Guest-home hero (design/19): cosmic photo card with the daily quote,
/// swipeable through the last few inspirations, page dots below.
class InspirationHeroCarousel extends StatefulWidget {
  const InspirationHeroCarousel({super.key, required this.items});

  final List<Inspiration> items;

  @override
  State<InspirationHeroCarousel> createState() =>
      _InspirationHeroCarouselState();
}

class _InspirationHeroCarouselState extends State<InspirationHeroCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 877 / 334,
          child: items.isEmpty
              ? const _HeroSlide(inspiration: null)
              : PageView(
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    for (final item in items) _HeroSlide(inspiration: item),
                  ],
                ),
        ),
        if (items.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < items.length; i++)
                Container(
                  width: i == _page ? 8 : 7,
                  height: i == _page ? 8 : 7,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: i == _page
                        ? JcfColors.skyPrimary
                        : const Color(0xFFB9C9F5),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({required this.inspiration});

  final Inspiration? inspiration;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final quote =
        inspiration == null ? t.defaultQuote : '\u201c${inspiration!.quote}\u201d';
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The comp's hero card is 310pt wide; k scales every measurement
          // so the overlays land exactly where the comp drew them.
          final k = constraints.maxWidth / 310;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/hero_full.png', fit: BoxFit.cover),
              PositionedDirectional(
                start: 13 * k,
                top: 11 * k,
                child: Text(
                  t.dailyInspirationEyebrow,
                  style: TextStyle(
                    color: const Color(0xFFB9C9F5),
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 7.5 * k,
                    letterSpacing: 2.4 * k,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PositionedDirectional(
                start: 5 * k,
                top: 23 * k,
                width: 166 * k,
                height: 56 * k,
                child: Center(
                  child: Text(
                    quote,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 13 * k,
                      height: 1.18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: 12 * k,
                bottom: 8 * k,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15 * k),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15 * k),
                    onTap: inspiration == null
                        ? null
                        : () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => InspirationDetailScreen(
                                  inspiration: inspiration!),
                            )),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 13 * k, vertical: 7 * k),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t.readReflection,
                            style: TextStyle(
                              color: JcfColors.skyPrimary,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 10.5 * k,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 5 * k),
                          Icon(Icons.chevron_right_rounded,
                              size: 12 * k, color: JcfColors.skyPrimary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: JcfColors.inkOnLight,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 18.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                visualDensity: VisualDensity.compact),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.seeAll,
                  style: const TextStyle(
                    color: JcfColors.skyPrimary,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 17, color: JcfColors.skyPrimary),
              ],
            ),
          ),
      ],
    );
  }
}

/// One shared title size for the three journey cards: the largest size at
/// which the longest title still fits one line, so the cards stay uniform.
double journeyTitleSize(List<String> titles, double innerWidth) {
  var size = 12.5;
  for (final title in titles) {
    final painter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontFamily: JcfTypography.bodyFamily,
          fontWeight: FontWeight.w800,
          fontSize: 100,
        ),
      ),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final fit = 100 * (innerWidth - 2) / painter.width;
    if (fit < size) size = fit;
  }
  return size;
}

class JourneyCard extends StatelessWidget {
  const JourneyCard({
    super.key,
    required this.leading,
    required this.tint,
    required this.bg,
    required this.title,
    required this.titleSize,
    required this.sub,
    required this.onTap,
  });

  final Widget leading;
  final Color tint;
  final Color bg;
  final String title;
  final double titleSize;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Soft halo blob behind the icon, as in the comp.
              PositionedDirectional(
                start: 10,
                top: -18,
                child: Container(
                  width: 104,
                  height: 74,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(48),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: 42,
                        width: double.infinity,
                        child: Center(child: leading)),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                      style: TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            sub.replaceAll('\n', ' '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _sub,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 8.5,
                              letterSpacing: -0.2,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            size: 15, color: Color(0xFF122B63)),
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

/// Live & Upcoming card (design/19): first item of the activities feed,
/// with a LIVE SOON eyebrow when a live session is imminent. The sunset
/// artwork bleeds in from the right edge like the comp.
class LiveUpcomingCard extends StatelessWidget {
  const LiveUpcomingCard({super.key, required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final when = item.allDay
        ? DateFormat('EEE, d MMM', locale).format(item.startsAt)
        : DateFormat.jm(locale).format(item.startsAt);
    final sub = item.description.isNotEmpty
        ? item.description
        : (item.venue.isEmpty ? t.onlineLabel : item.venue);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () => item.programSlug != null
              ? context.push('/programs/${item.programSlug}')
              : context.push('/activities'),
          child: Stack(
            children: [
              // Sunset artwork bleeding in from the trailing edge.
              Positioned.fill(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FractionallySizedBox(
                    alignment: AlignmentDirectional.centerEnd,
                    widthFactor: 0.52,
                    heightFactor: 1,
                    child: ShaderMask(
                      shaderCallback: (rect) => const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.transparent, Colors.white],
                        stops: [0.0, 0.45],
                      ).createShader(rect),
                      blendMode: BlendMode.dstIn,
                      child: Image.asset(
                        'assets/images/live_upcoming.png',
                        fit: BoxFit.cover,
                        alignment: AlignmentDirectional.centerEnd,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFFE3EEFF),
                      child: Icon(Icons.calendar_month_rounded,
                          color: JcfColors.skyPrimary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.liveSoon) ...[
                            Row(
                              children: [
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE02D3C),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  t.liveSoonBadge.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFFE02D3C),
                                    fontFamily: JcfTypography.bodyFamily,
                                    fontSize: 11,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                          ],
                          Text(
                            '${item.title} \u2022 $when',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: JcfColors.inkOnLight,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 14,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            sub,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _sub,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Keep the text clear of the baked caption + chevron.
                    const SizedBox(width: 104),
                  ],
                ),
              ),
              const PositionedDirectional(
                end: 6,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF122B63), size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpcomingProgramCard extends StatelessWidget {
  const UpcomingProgramCard({super.key, required this.program});

  final Program program;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/programs/${program.slug}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFE3EEFF),
                child: Icon(Icons.event_rounded, color: JcfColors.skyPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${program.title} (${program.year})',
                      style: const TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (program.venue.isNotEmpty)
                      Text(
                        program.venue,
                        style: const TextStyle(
                            color: _sub,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 14),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _muted),
            ],
          ),
        ),
      ),
    );
  }
}

class TeachingCard extends StatelessWidget {
  const TeachingCard({super.key, required this.teaching});

  final Teaching teaching;

  String get _duration {
    final s = teaching.durationSeconds;
    if (s == null || s == 0) return '';
    final m = (s ~/ 60).toString();
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/lessons/${teaching.slug}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: teaching.thumbnailUrl.isEmpty
                        ? Image.asset(
                            'assets/images/teaching_thumb.png',
                            height: 74,
                            width: 110,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            teaching.thumbnailUrl,
                            height: 74,
                            width: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Image.asset(
                              'assets/images/teaching_thumb.png',
                              height: 74,
                              width: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  if (_duration.isNotEmpty)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(_duration,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teaching.topic,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 15,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      teaching.author.isNotEmpty
                          ? teaching.author
                          : teaching.format,
                      style: const TextStyle(
                          color: _sub,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 13),
                    ),
                    if (teaching.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        teaching.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: _sub,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 12.5,
                            height: 1.3),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.more_vert_rounded, color: _muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInBanner extends StatelessWidget {
  const SignInBanner(
      {super.key, required this.title, required this.sub, required this.cta});

  final String title;
  final String sub;
  final String cta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3EEFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFCFE0FB),
            child: Icon(Icons.groups_rounded,
                color: JcfColors.skyPrimary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: JcfColors.inkOnLight,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _sub,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 11.5,
                      height: 1.25),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: () => context.push('/login'),
            icon: const Icon(Icons.arrow_forward, size: 16),
            iconAlignment: IconAlignment.end,
            label: Text(cta),
            style: FilledButton.styleFrom(
              backgroundColor: JcfColors.skyPrimary,
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              textStyle: const TextStyle(
                fontSize: 13.5,
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

class EyebrowCard extends StatelessWidget {
  const EyebrowCard({
    super.key,
    required this.eyebrow,
    required this.icon,
    required this.title,
    required this.ctaLabel,
    required this.onTap,
  });

  final String eyebrow;
  final IconData icon;
  final String title;
  final String ctaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE3EEFF),
                child: Icon(icon, size: 20, color: JcfColors.skyPrimary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  eyebrow,
                  style: const TextStyle(
                    color: _sub,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 10.5,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: JcfColors.inkOnLight,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 17,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.chevron_right, size: 18),
              iconAlignment: IconAlignment.end,
              label: Text(ctaLabel, overflow: TextOverflow.ellipsis),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE3EEFF),
                foregroundColor: JcfColors.skyPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: JcfTypography.bodyFamily,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickAction {
  const QuickAction(
      this.icon, this.tint, this.bg, this.label, this.sub, this.onTap);
  final IconData icon;
  final Color tint;
  final Color bg;
  final String label;
  final String sub;
  final VoidCallback onTap;
}

class QuickActionRow extends StatelessWidget {
  const QuickActionRow({super.key, required this.items});

  final List<QuickAction> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final item in items)
          Expanded(
            child: InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: item.bg,
                    child: Icon(item.icon, color: item.tint, size: 28),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: JcfColors.inkOnLight,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    item.sub,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: _sub,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.announcementEyebrow,
            style: const TextStyle(
              color: JcfColors.skyPrimary,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            announcement.title,
            style: const TextStyle(
              color: JcfColors.inkOnLight,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            announcement.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: _sub,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 14.5,
                height: 1.3),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.push('/announcements'),
              icon: const Icon(Icons.chevron_right, size: 18),
              iconAlignment: IconAlignment.end,
              label: Text(t.learnMore),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE3EEFF),
                foregroundColor: JcfColors.skyPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: JcfTypography.bodyFamily,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Student journey hero (design/21) — level/progress data arrives with the
/// practice/progress slices; until then it carries the user into Learn.
class JourneyHero extends StatelessWidget {
  const JourneyHero(
      {super.key, required this.eyebrow, required this.cta,
      required this.onTap});

  final String eyebrow;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1668), Color(0xFF1B3BD8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: Color(0xFFB9C9F5),
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: JcfLogo(size: 84, onDark: true),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(cta),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: JcfColors.skyPrimary,
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
          ),
        ],
      ),
    );
  }
}

class TodaysPracticeCard extends StatelessWidget {
  const TodaysPracticeCard(
      {super.key, required this.title, required this.cta,
      required this.onTap, this.streakLabel});

  final String title;
  final String cta;
  final VoidCallback onTap;
  final String? streakLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFDDF3E4),
            child:
                Icon(Icons.spa_rounded, color: Color(0xFF2E9E5B), size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: JcfColors.inkOnLight,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (streakLabel != null)
                  Text(
                    streakLabel!,
                    style: const TextStyle(
                      color: Color(0xFFF08A24),
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: Text(cta),
            style: FilledButton.styleFrom(
              backgroundColor: JcfColors.skyPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              textStyle: const TextStyle(
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
