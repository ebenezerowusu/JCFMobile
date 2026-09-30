import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import 'activities_controller.dart';
import 'activities_filter_sheet.dart';
import 'activity_detail_sheet.dart';
import 'activity_models.dart';
import 'activity_widgets.dart';

const _muted = Color(0xFF54689B);
const _hairline = Color(0xFFE3EAF7);

/// Upcoming Activities (designs 37–41).
///
/// A week selector and four chips above a dated, infinitely scrolling list,
/// with a calendar view behind a toggle. Everything about an activity's
/// state — whether it is live, whether registration is open, whether the
/// reader may attend — comes from the server; this screen renders it.
class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _searching = false;
  DateTime? _weekStart;
  late DateTime _calendarMonth = _firstOfThisMonth();

  static DateTime _firstOfThisMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // Fetch a screenful early so the list rarely shows its own spinner.
    if (position.pixels >= position.maxScrollExtent - 600) {
      ref.read(activitiesControllerProvider.notifier).loadMore();
    }
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final state = ref.watch(activitiesControllerProvider);
    final view = ref.watch(activitiesViewProvider);
    _weekStart ??= WeekSelector.startOfWeek(context, _today);

    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(t, view),
            _chipRow(t, state),
            if (view == ActivitiesView.list)
              WeekSelector(
                weekStart: _weekStart!,
                selected: state.query.from,
                today: _today,
                onSelect: _selectDay,
                onPreviousWeek: () => setState(() => _weekStart =
                    _weekStart!.subtract(const Duration(days: 7))),
                onNextWeek: () => setState(() =>
                    _weekStart = _weekStart!.add(const Duration(days: 7))),
              ),
            if (state.fromCache) _cacheNotice(t, state),
            Expanded(
              child: view == ActivitiesView.calendar
                  ? _calendarView(t, state)
                  : _listView(t, state),
            ),
          ],
        ),
      ),
    );
  }

  // --- chrome ----------------------------------------------------------

  Widget _header(AppLocalizations t, ActivitiesView view) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
        child: Row(
          children: [
            IconButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
              icon: const Icon(Icons.arrow_back_rounded),
              color: JcfColors.inkOnLight,
            ),
            Expanded(
              child: _searching
                  ? _searchField(t)
                  : Text(
                      t.upcomingActivitiesTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: JcfColors.inkOnLight,
                      ),
                    ),
            ),
            IconButton(
              onPressed: _toggleSearch,
              tooltip: t.activitiesSearchHint,
              icon: Icon(_searching
                  ? Icons.close_rounded
                  : Icons.search_rounded),
              color: JcfColors.inkOnLight,
            ),
            IconButton(
              onPressed: () => ref
                  .read(activitiesViewProvider.notifier)
                  .set(view == ActivitiesView.list
                      ? ActivitiesView.calendar
                      : ActivitiesView.list),
              tooltip: view == ActivitiesView.list
                  ? t.activitiesCalendarView
                  : t.activitiesListView,
              icon: Icon(view == ActivitiesView.list
                  ? Icons.calendar_month_rounded
                  : Icons.view_agenda_rounded),
              color: JcfColors.inkOnLight,
            ),
          ],
        ),
      );

  Widget _searchField(AppLocalizations t) => TextField(
        controller: _searchController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onChanged: (value) =>
            ref.read(activitiesControllerProvider.notifier).search(value),
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: t.activitiesSearchHint,
          isDense: true,
          border: InputBorder.none,
          hintStyle: const TextStyle(color: _muted, fontSize: 15),
        ),
      );

  void _toggleSearch() {
    setState(() => _searching = !_searching);
    if (!_searching) {
      _searchController.clear();
      ref.read(activitiesControllerProvider.notifier).search('');
    }
  }

  Widget _chipRow(AppLocalizations t, ActivitiesState state) {
    final chips = <(PrimaryFilter, String)>[
      (PrimaryFilter.all, t.activitiesChipAll),
      (PrimaryFilter.live, t.activitiesChipLive),
      (PrimaryFilter.online, t.activitiesChipOnline),
      (PrimaryFilter.inPerson, t.activitiesChipInPerson),
    ];
    // The four chips scroll; the filter button is pinned beside them.
    // Letting it scroll off the edge hides the only way into the advanced
    // filters behind a gesture nothing suggests.
    return SizedBox(
      height: 46,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              children: [
                for (final chip in chips) ...[
                  _filterChip(
                    label: chip.$2,
                    selected: state.query.primary == chip.$1,
                    onTap: () => ref
                        .read(activitiesControllerProvider.notifier)
                        .setPrimaryFilter(chip.$1),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 16),
            child: KeyedSubtree(
              key: const ValueKey('activities-filter-button'),
              child: _filterChip(
                label: state.query.advancedCount > 0
                    ? '${state.query.advancedCount}'
                    : '',
                selected: state.query.advancedCount > 0,
                icon: Icons.tune_rounded,
                tooltip:
                    t.activitiesFilterCount(state.query.advancedCount),
                onTap: () => _openFilters(state),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
    String? tooltip,
  }) =>
      Center(
        child: Semantics(
          selected: selected,
          button: true,
          label: tooltip,
          child: Tooltip(
            message: tooltip ?? label,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: label.isEmpty ? 10 : 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? JcfColors.skyPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected ? JcfColors.skyPrimary : _hairline,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null)
                      Icon(icon,
                          size: 16,
                          color: selected ? Colors.white : _muted),
                    if (icon != null && label.isNotEmpty)
                      const SizedBox(width: 5),
                    if (label.isNotEmpty)
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : _muted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _openFilters(ActivitiesState state) async {
    final chosen = await ActivitiesFilterSheet.show(
      context,
      initial: state.query,
      available: state.availableFilters,
    );
    if (chosen == null || !mounted) return;
    ref.read(activitiesControllerProvider.notifier)
        .setAdvancedFilters(chosen);
  }

  Widget _cacheNotice(AppLocalizations t, ActivitiesState state) {
    final locale = Localizations.localeOf(context).toString();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              t.activitiesOfflineNotice(_savedAt(locale, state)),
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF8A4B00)),
            ),
          ),
        ],
      ),
    );
  }

  /// When the copy on screen was saved, written as a time if that was
  /// today and as a date otherwise.
  String _savedAt(String locale, ActivitiesState state) {
    final saved = state.cachedAt ?? DateTime.now();
    return _sameDay(saved, _today)
        ? DateFormat.jm(locale).format(saved)
        : DateFormat('d MMM', locale).add_jm().format(saved);
  }

  void _selectDay(DateTime day) {
    final controller = ref.read(activitiesControllerProvider.notifier);
    final current = ref.read(activitiesControllerProvider).query.from;
    // Tapping the chosen day again clears it, which is the only way back
    // to the full schedule without hunting for a "show all" control.
    if (current != null && _sameDay(current, day)) {
      controller.selectDay(null);
    } else {
      controller.selectDay(day);
    }
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // --- list ------------------------------------------------------------

  Widget _listView(AppLocalizations t, ActivitiesState state) {
    if (state.loading && state.items.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => const ActivitySkeleton(),
      );
    }
    if (state.isFatalError) {
      return ListView(
        children: [
          ActivityPlaceholder(
            icon: Icons.wifi_off_rounded,
            title: t.activitiesLoadFailed,
            body: t.activitiesLoadFailedBody,
            actionLabel: t.activitiesRetry,
            onAction: () =>
                ref.read(activitiesControllerProvider.notifier).load(),
          ),
        ],
      );
    }
    if (state.isEmpty) {
      final filtered = state.query.hasAnyFilter;
      return RefreshIndicator(
        onRefresh: () => ref
            .read(activitiesControllerProvider.notifier)
            .load(refresh: true),
        child: ListView(
          children: [
            ActivityPlaceholder(
              icon: filtered
                  ? Icons.filter_alt_off_rounded
                  : Icons.event_available_rounded,
              title: filtered
                  ? t.activitiesNoMatches
                  : t.activitiesNothingScheduled,
              body: filtered
                  ? t.activitiesNoMatchesBody
                  : t.activitiesNothingScheduledBody,
              actionLabel:
                  filtered ? t.activitiesFilterClearAll : null,
              onAction: filtered
                  ? () {
                      _searchController.clear();
                      ref
                          .read(activitiesControllerProvider.notifier)
                          .clearAllFilters();
                    }
                  : null,
            ),
          ],
        ),
      );
    }

    final rows = _buildRows(t, state);
    return RefreshIndicator(
      onRefresh: () => ref
          .read(activitiesControllerProvider.notifier)
          .load(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: rows.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= rows.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
            );
          }
          return rows[index];
        },
      ),
    );
  }

  /// Flattens the page into featured card, day headings and cards.
  List<Widget> _buildRows(AppLocalizations t, ActivitiesState state) {
    final locale = Localizations.localeOf(context).toString();
    final rows = <Widget>[];
    if (state.featured != null) {
      rows
        ..add(FeaturedActivityCard(
          activity: state.featured!,
          onOpen: () => _open(state.featured!),
        ))
        ..add(const SizedBox(height: 18));
    }
    DateTime? currentDay;
    for (final activity in state.items) {
      if (currentDay == null || !_sameDay(currentDay, activity.localDay)) {
        currentDay = activity.localDay;
        rows.add(Padding(
          padding: EdgeInsets.only(
              top: rows.isEmpty ? 0 : 18, bottom: 10),
          child: Row(
            children: [
              ActivityDateBlock(
                date: currentDay,
                dimmed: currentDay.isBefore(_today),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dayHeading(t, locale, currentDay, DateTime.now()),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: JcfColors.inkOnLight,
                  ),
                ),
              ),
            ],
          ),
        ));
      } else {
        rows.add(const SizedBox(height: 12));
      }
      rows.add(ActivityCard(
        key: ValueKey('activity-${activity.id}'),
        activity: activity,
        onOpen: () => _open(activity),
        onReminder: () => _toggleReminder(activity),
        onSave: () => _toggleSave(activity),
        onRegister: () => _register(activity),
      ));
    }
    return rows;
  }

  // --- calendar --------------------------------------------------------

  Widget _calendarView(AppLocalizations t, ActivitiesState state) {
    final locale = Localizations.localeOf(context).toString();
    final days = ref.watch(activityCalendarProvider(_calendarMonth));
    final selected = state.query.from;
    final onDay = selected == null
        ? const <Activity>[]
        : [
            for (final activity in state.items)
              if (_sameDay(activity.localDay, selected)) activity
          ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _hairline),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _calendarMonth =
                        DateTime(_calendarMonth.year,
                            _calendarMonth.month - 1, 1)),
                    tooltip: t.activitiesPreviousMonth,
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: _muted,
                  ),
                  Expanded(
                    child: Text(
                      DateFormat('MMMM yyyy', locale)
                          .format(_calendarMonth),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: JcfColors.inkOnLight,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _calendarMonth =
                        DateTime(_calendarMonth.year,
                            _calendarMonth.month + 1, 1)),
                    tooltip: t.activitiesNextMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: _muted,
                  ),
                ],
              ),
              ActivityCalendarGrid(
                month: _calendarMonth,
                days: days.asData?.value ?? const [],
                selected: selected,
                today: _today,
                onSelect: _selectDay,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (selected == null)
          ActivityPlaceholder(
            icon: Icons.touch_app_rounded,
            title: t.activitiesCalendarView,
            body: t.activitiesNothingScheduledBody,
          )
        else if (state.loading)
          const ActivitySkeleton()
        else if (onDay.isEmpty)
          ActivityPlaceholder(
            icon: Icons.event_available_rounded,
            title: t.activitiesNothingScheduled,
            body: t.activitiesNothingScheduledBody,
            actionLabel: t.activitiesClearDay,
            onAction: () => ref
                .read(activitiesControllerProvider.notifier)
                .selectDay(null),
          )
        else
          for (final activity in onDay) ...[
            ActivityCard(
              key: ValueKey('calendar-activity-${activity.id}'),
              activity: activity,
              onOpen: () => _open(activity),
              onReminder: () => _toggleReminder(activity),
              onSave: () => _toggleSave(activity),
              onRegister: () => _register(activity),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  // --- actions ---------------------------------------------------------

  void _open(Activity activity) {
    final t = AppLocalizations.of(context)!;
    if (!activity.access.allowed) {
      if (activity.access.signInRequired) {
        context.push('/login');
      } else {
        _snack(activity.access.reason == 'students_only'
            ? t.activitiesStudentsOnly
            : t.activitiesMembersOnly);
      }
      return;
    }
    // The server names a destination; the app owns the route. A live
    // session opens the player; anything else opens a sheet built from the
    // row already in hand, which costs no request and keeps the reader's
    // place in the schedule.
    if (activity.destination.type == 'live') {
      context.push('/live/${activity.destination.eventId}');
      return;
    }
    ActivityDetailSheet.show(
      context,
      activity: activity,
      onReminder: () => _toggleReminder(activity),
      onSave: () => _toggleSave(activity),
      onRegister: () => _register(activity),
    );
  }

  bool _requireSignIn() {
    if (!ref.read(isLoggedInProvider)) {
      context.push('/login');
      return true;
    }
    return false;
  }

  Future<void> _toggleReminder(Activity activity) async {
    if (_requireSignIn()) return;
    final t = AppLocalizations.of(context)!;
    final wasOn = activity.reminderSet;
    final ok = await ref
        .read(activitiesControllerProvider.notifier)
        .toggleReminder(activity);
    if (!mounted) return;
    _snack(ok
        ? (wasOn ? t.reminderOffSnack : t.reminderOnSnack)
        : t.genericError);
  }

  Future<void> _toggleSave(Activity activity) async {
    if (_requireSignIn()) return;
    final t = AppLocalizations.of(context)!;
    final wasSaved = activity.saved;
    final ok = await ref
        .read(activitiesControllerProvider.notifier)
        .toggleSave(activity);
    if (!mounted) return;
    _snack(ok
        ? (wasSaved ? t.activitiesUnsavedSnack : t.activitiesSavedSnack)
        : t.genericError);
  }

  Future<void> _register(Activity activity) async {
    final t = AppLocalizations.of(context)!;
    if (activity.registration.state == RegistrationState.external) {
      final url = Uri.tryParse(activity.registration.externalUrl);
      if (url != null) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return;
    }
    if (_requireSignIn()) return;

    final cancelling =
        activity.registration.mine != MyRegistration.none &&
            activity.registration.mine != MyRegistration.cancelled;
    final info = await ref
        .read(activitiesControllerProvider.notifier)
        .register(activity, cancel: cancelling);
    if (!mounted) return;
    if (info == null) {
      _snack(t.activitiesRegistrationFailed);
      return;
    }
    _snack(switch (info.mine) {
      MyRegistration.registered =>
        t.activitiesRegistrationConfirmed(activity.title),
      MyRegistration.waitlisted =>
        t.activitiesWaitlistConfirmed(activity.title),
      _ => t.activitiesPlaceReleased,
    });
  }

  void _snack(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}
