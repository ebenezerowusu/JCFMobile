import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jcf_models/jcf_models.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import 'engagement_repository.dart';

const _sub = Color(0xFF54689B);

/// Announcements (design/28): audience filter chips, a pinned card, unread
/// dots that clear when an announcement is opened.
class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  String _filter = 'all';

  bool _matches(Announcement a) => switch (_filter) {
        'public' => a.audience == 'public',
        'members' => a.audience == 'members',
        'students' => a.audience == 'students',
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final feed = ref.watch(announcementsProvider);

    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      appBar: AppBar(
        backgroundColor: JcfColors.skySurface,
        elevation: 0,
        foregroundColor: JcfColors.inkOnLight,
        title: Text(
          t.announcementsTitle,
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
            onPressed: () => ref.invalidate(announcementsProvider),
            child: Text(t.genericError),
          ),
        ),
        data: (page) {
          final visible = page.results.where(_matches).toList();
          final pinned = visible.where((a) => a.pinned).toList();
          final rest = visible.where((a) => !a.pinned).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              Text(
                t.announcementsTagline,
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
              const SizedBox(height: 16),
              if (visible.isEmpty) ...[
                const SizedBox(height: 50),
                const Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Color(0xFFE3EEFF),
                    child: Icon(Icons.campaign_rounded,
                        size: 40, color: JcfColors.skyPrimary),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    t.noAnnouncements,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _sub,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
              for (final a in pinned) ...[
                _AnnouncementCard(announcement: a, highlighted: true),
                const SizedBox(height: 12),
              ],
              for (final a in rest) ...[
                _AnnouncementCard(announcement: a),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
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
      ('public', t.chipGeneral),
      ('members', t.chipMembers),
      ('students', t.chipStudents),
    ];
    return Row(
      children: [
        for (final (key, label) in options) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: value == key
                      ? JcfColors.skyPrimary
                      : Colors.white.withValues(alpha: .8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: value == key ? Colors.white : JcfColors.inkOnLight,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 13.5,
                    fontWeight:
                        value == key ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          if (key != 'students') const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _AnnouncementCard extends ConsumerWidget {
  const _AnnouncementCard(
      {required this.announcement, this.highlighted = false});

  final Announcement announcement;
  final bool highlighted;

  (String, Color, Color) _audienceLook(AppLocalizations t) =>
      switch (announcement.audience) {
        'members' => (t.chipMembers, const Color(0xFF7B5BD6),
            const Color(0xFFEAE3FA)),
        'students' => (t.chipStudents, const Color(0xFF2E9E5B),
            const Color(0xFFDDF3E4)),
        _ => (t.chipGeneral, const Color(0xFFF08A24),
            const Color(0xFFFDEED9)),
      };

  String _dateLabel(BuildContext context, AppLocalizations t) {
    final raw = announcement.createdAt;
    if (raw == null) return '';
    final when = DateTime.tryParse(raw)?.toLocal();
    if (when == null) return '';
    final locale = Localizations.localeOf(context).toString();
    if (DateUtils.isSameDay(when, DateTime.now())) return t.todaySection;
    return DateFormat('d MMM', locale).format(when);
  }

  void _open(BuildContext context, WidgetRef ref) {
    if (!announcement.isRead && ref.read(isLoggedInProvider)) {
      ref
          .read(engagementRepositoryProvider)
          .markAnnouncementRead(announcement.id)
          .then((_) => ref.invalidate(announcementsProvider))
          .catchError((_) {});
    }
    final t = AppLocalizations.of(context)!;
    final (audienceLabel, audienceTint, audienceBg) = _audienceLook(t);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (announcement.imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    announcement.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                announcement.title,
                style: const TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
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
                  const Spacer(),
                  Text(
                    _dateLabel(context, t),
                    style: const TextStyle(
                      color: _sub,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    announcement.body,
                    style: const TextStyle(
                      color: _sub,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 16,
                      height: 1.5,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final (audienceLabel, audienceTint, audienceBg) = _audienceLook(t);

    return Material(
      color: highlighted ? const Color(0xFFE3EEFF) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _open(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (announcement.imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      announcement.imageUrl,
                      width: 74,
                      height: 74,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 74,
                        height: 74,
                        color: const Color(0xFFE3EEFF),
                        child: const Icon(Icons.campaign_rounded,
                            color: JcfColors.skyPrimary),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 74,
                  height: 74,
                  margin: const EdgeInsetsDirectional.only(end: 12),
                  decoration: BoxDecoration(
                    color: highlighted ? Colors.white : const Color(0xFFE3EEFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.campaign_rounded,
                      size: 32, color: JcfColors.skyPrimary),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (highlighted) ...[
                      Row(
                        children: [
                          const Icon(Icons.push_pin_rounded,
                              size: 15, color: JcfColors.skyPrimary),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              t.pinnedAnnouncement,
                              style: const TextStyle(
                                color: JcfColors.skyPrimary,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            _dateLabel(context, t),
                            style: const TextStyle(
                              color: _sub,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!announcement.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsetsDirectional.only(
                                end: 7, top: 6),
                            decoration: const BoxDecoration(
                              color: JcfColors.skyPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            announcement.title,
                            style: const TextStyle(
                              color: JcfColors.inkOnLight,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!highlighted) ...[
                          const SizedBox(width: 6),
                          Text(
                            _dateLabel(context, t),
                            style: const TextStyle(
                              color: _sub,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      announcement.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _sub,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
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
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded,
                            color: _sub, size: 22),
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
