import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../home/member_home_widgets.dart' show MemberImage;
import 'activity_models.dart';
import 'activity_widgets.dart';

const _muted = Color(0xFF54689B);

/// The full account of one activity.
///
/// A sheet rather than a screen: everything it shows already arrived with
/// the list row, so opening it costs no request and closing it returns the
/// reader to their place in the schedule. A live activity never reaches
/// here — it goes straight to the player.
class ActivityDetailSheet extends StatelessWidget {
  const ActivityDetailSheet({
    super.key,
    required this.activity,
    required this.onReminder,
    required this.onSave,
    required this.onRegister,
  });

  final Activity activity;
  final VoidCallback onReminder;
  final VoidCallback onSave;
  final VoidCallback onRegister;

  static Future<void> show(
    BuildContext context, {
    required Activity activity,
    required VoidCallback onReminder,
    required VoidCallback onSave,
    required VoidCallback onRegister,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => ActivityDetailSheet(
          activity: activity,
          onReminder: onReminder,
          onSave: onSave,
          onRegister: onRegister,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final media = MediaQuery.of(context);
    final cta = registrationCta(t, locale, activity);
    final facilitator = activity.facilitator;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24)),
                    child: MemberImage(
                      url: activity.imageUrl,
                      asset: activityAsset(
                          activity.imageKey, activity.activityType),
                      width: double.infinity,
                      height: 172,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: activityBadges(t, activity),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          activity.title,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            color: JcfColors.inkOnLight,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _row(
                          Icons.event_rounded,
                          DateFormat('EEEE, d MMMM yyyy', locale)
                              .format(activity.startsAt),
                          timeLine(t, locale, activity),
                        ),
                        if (activity.locationLine.isNotEmpty)
                          _row(
                            activity.format == ActivityFormat.online
                                ? Icons.videocam_rounded
                                : Icons.place_rounded,
                            activity.locationLine,
                            formatLabel(t, activity.format),
                          ),
                        if (facilitator != null)
                          _row(
                            Icons.person_rounded,
                            facilitator.displayName,
                            facilitator.role,
                          ),
                        if (!activity.fee.free)
                          _row(Icons.payments_rounded,
                              activity.fee.display, ''),
                        if (activity.registration.required_ &&
                            activity.registration.seatsLeft != null)
                          _row(
                            Icons.event_seat_rounded,
                            t.activitiesSeatsLeft(
                                activity.registration.seatsLeft!),
                            '',
                          ),
                        if (activity.rescheduledNote.isNotEmpty)
                          _row(Icons.update_rounded,
                              t.activitiesRescheduled,
                              activity.rescheduledNote),
                        if (activity.summary.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            activity.summary,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.55,
                              color: Color(0xFF3E3B46),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Color(0xFFE3EAF7))),
              ),
              child: Row(
                children: [
                  _circleAction(
                    icon: activity.reminderSet
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    active: activity.reminderSet,
                    tooltip: t.remindMe,
                    onPressed: onReminder,
                  ),
                  const SizedBox(width: 8),
                  _circleAction(
                    icon: activity.saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    active: activity.saved,
                    tooltip: t.saveForLater,
                    onPressed: onSave,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: activity.registration.required_ &&
                              cta.enabled
                          ? onRegister
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: JcfColors.skyPrimary,
                        disabledBackgroundColor:
                            const Color(0xFFF1F3F8),
                        disabledForegroundColor: _muted,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      child: Text(activity.registration.required_
                          ? cta.label
                          : t.addToCalendar),
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

  Widget _row(IconData icon, String title, String subtitle) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: JcfColors.skyPrimary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: JcfColors.inkOnLight,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 12.5, color: _muted),
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _circleAction({
    required IconData icon,
    required bool active,
    required String tooltip,
    required VoidCallback onPressed,
  }) =>
      Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? const Color(0xFFE8F0FF)
                  : const Color(0xFFF4F7FC),
              border: Border.all(
                color: active
                    ? JcfColors.skyPrimary
                    : const Color(0xFFE3EAF7),
              ),
            ),
            child: Icon(icon,
                size: 20,
                color: active ? JcfColors.skyPrimary : _muted),
          ),
        ),
      );
}
