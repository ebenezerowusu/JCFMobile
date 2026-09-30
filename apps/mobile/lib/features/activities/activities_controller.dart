import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_controller.dart';
import 'activities_repository.dart';
import 'activity_models.dart';

/// How long typing pauses before a search reaches the network.
const searchDebounce = Duration(milliseconds: 350);

const _viewModeKey = 'activities.view_mode.v1';

enum ActivitiesView { list, calendar }

@immutable
class ActivitiesState {
  const ActivitiesState({
    this.query = const ActivityQuery(),
    this.items = const [],
    this.featured,
    this.availableFilters = const AvailableFilters(),
    this.nextCursor,
    this.loading = true,
    this.loadingMore = false,
    this.refreshing = false,
    this.error,
    this.fromCache = false,
    this.cacheIsStale = false,
    this.cachedAt,
    this.serverTime,
  });

  final ActivityQuery query;
  final List<Activity> items;
  final Activity? featured;
  final AvailableFilters availableFilters;
  final String? nextCursor;

  /// First load for the current query — the screen shows skeletons.
  final bool loading;

  /// A further page is on its way — a spinner at the foot of the list.
  final bool loadingMore;

  /// Pull-to-refresh; the existing list stays on screen.
  final bool refreshing;
  final Object? error;

  /// True while what is on screen came off disk rather than the network.
  final bool fromCache;
  final bool cacheIsStale;

  /// When the copy on screen was written to disk. The notice names this,
  /// not the current time — a saved copy that claims to be from "now" is
  /// worse than no notice at all.
  final DateTime? cachedAt;
  final DateTime? serverTime;

  bool get hasMore => nextCursor != null;

  /// An error that leaves nothing readable behind is a full-screen state;
  /// one with a list still showing is a snack bar.
  bool get isFatalError => error != null && items.isEmpty;

  bool get isEmpty => !loading && error == null && items.isEmpty;

  ActivitiesState copyWith({
    ActivityQuery? query,
    List<Activity>? items,
    Activity? featured,
    bool clearFeatured = false,
    AvailableFilters? availableFilters,
    String? nextCursor,
    bool clearCursor = false,
    bool? loading,
    bool? loadingMore,
    bool? refreshing,
    Object? error,
    bool clearError = false,
    bool? fromCache,
    bool? cacheIsStale,
    DateTime? cachedAt,
    DateTime? serverTime,
  }) =>
      ActivitiesState(
        query: query ?? this.query,
        items: items ?? this.items,
        featured: clearFeatured ? null : (featured ?? this.featured),
        availableFilters: availableFilters ?? this.availableFilters,
        nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        refreshing: refreshing ?? this.refreshing,
        error: clearError ? null : (error ?? this.error),
        fromCache: fromCache ?? this.fromCache,
        cacheIsStale: cacheIsStale ?? this.cacheIsStale,
        cachedAt: cachedAt ?? this.cachedAt,
        serverTime: serverTime ?? this.serverTime,
      );
}

class ActivitiesController extends Notifier<ActivitiesState> {
  late ActivitiesRepository _repository;
  Timer? _searchTimer;

  /// Guards against a slow first request landing after a newer one. Every
  /// load claims a ticket; a reply holding a stale ticket is dropped.
  int _requestTicket = 0;

  @override
  ActivitiesState build() {
    // Sign-in and sign-out change what is visible and what is unlocked.
    ref.watch(authControllerProvider);
    _repository = ref.watch(activitiesRepositoryProvider);
    ref.onDispose(() => _searchTimer?.cancel());
    Future.microtask(load);
    return const ActivitiesState();
  }

  Future<void> load({bool refresh = false}) async {
    final ticket = ++_requestTicket;
    state = state.copyWith(
      loading: !refresh && state.items.isEmpty,
      refreshing: refresh,
      clearError: true,
    );

    if (!refresh && state.items.isEmpty && !state.query.hasAnyFilter) {
      await _showCacheWhileLoading(ticket);
    }

    try {
      final page = await _repository.browse(query: state.query);
      if (ticket != _requestTicket) return;
      state = state.copyWith(
        items: page.results,
        featured: page.featured,
        clearFeatured: page.featured == null,
        availableFilters: page.availableFilters,
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        serverTime: page.serverTime,
        loading: false,
        refreshing: false,
        fromCache: false,
        cacheIsStale: false,
        clearError: true,
      );
    } catch (error) {
      if (ticket != _requestTicket) return;
      state = state.copyWith(
        loading: false,
        refreshing: false,
        // A cached list on screen survives a failed refresh; the caller
        // decides whether to say so in a snack bar.
        error: error,
      );
    }
  }

  Future<void> _showCacheWhileLoading(int ticket) async {
    final cached = await _repository.cachedFirstPage();
    if (cached == null || ticket != _requestTicket) return;
    // Only fill an empty screen — never overwrite fresher network results.
    if (state.items.isNotEmpty) return;
    state = state.copyWith(
      items: cached.page.results,
      featured: cached.page.featured,
      availableFilters: cached.page.availableFilters,
      loading: false,
      fromCache: true,
      cacheIsStale: cached.isStale,
      cachedAt: cached.cachedAt,
    );
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loadingMore || state.loading) return;
    final ticket = _requestTicket;
    state = state.copyWith(loadingMore: true);
    try {
      final page = await _repository.browse(
          query: state.query, cursor: cursor);
      if (ticket != _requestTicket) return;
      // The server pages on (starts_at, id), but a row edited between
      // pages could still arrive twice. Dedupe by id so the list never
      // shows the same activity in two places.
      final seen = {for (final item in state.items) item.id};
      final merged = [
        ...state.items,
        ...page.results.where((item) => seen.add(item.id)),
      ];
      state = state.copyWith(
        items: merged,
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        loadingMore: false,
      );
    } catch (error) {
      if (ticket != _requestTicket) return;
      state = state.copyWith(loadingMore: false, error: error);
    }
  }

  /// Every filter change drops the cursor and the list together — keeping a
  /// cursor from the old query would silently skip the new first page.
  void _applyQuery(ActivityQuery query) {
    if (query == state.query) return;
    state = state.copyWith(
      query: query,
      items: const [],
      clearCursor: true,
      clearError: true,
      loading: true,
    );
    load();
  }

  void setPrimaryFilter(PrimaryFilter filter) =>
      _applyQuery(state.query.copyWith(primary: filter));

  void setAdvancedFilters(ActivityQuery draft) => _applyQuery(
        state.query.copyWith(
          types: draft.types,
          languages: draft.languages,
          fee: draft.fee,
          openToMeOnly: draft.openToMeOnly,
        ),
      );

  void selectDay(DateTime? day) => _applyQuery(
        day == null
            ? state.query.copyWith(clearDates: true)
            : state.query.copyWith(from: day, to: day),
      );

  void selectRange(DateTime from, DateTime to) =>
      _applyQuery(state.query.copyWith(from: from, to: to));

  /// Debounced so a search is one request per pause, not one per keystroke.
  void search(String text) {
    _searchTimer?.cancel();
    if (text.trim() == state.query.search) return;
    _searchTimer = Timer(searchDebounce, () {
      _applyQuery(state.query.copyWith(search: text.trim()));
    });
  }

  void clearAllFilters() => _applyQuery(const ActivityQuery());

  // --- per-item actions -------------------------------------------------
  //
  // Each flips the card at once and puts the old value back if the server
  // disagrees, so a tap never waits on the network to look like it worked.

  Future<bool> toggleReminder(Activity activity) async {
    _replace(activity.copyWith(reminderSet: !activity.reminderSet));
    try {
      final on = await _repository.toggleReminder(activityId: activity.id);
      _replace(_find(activity.id)?.copyWith(reminderSet: on));
      return true;
    } catch (_) {
      _replace(_find(activity.id)?.copyWith(
          reminderSet: activity.reminderSet));
      return false;
    }
  }

  Future<bool> toggleSave(Activity activity) async {
    _replace(activity.copyWith(saved: !activity.saved));
    try {
      final saved = await _repository.toggleSave(activity.id);
      _replace(_find(activity.id)?.copyWith(saved: saved));
      return true;
    } catch (_) {
      _replace(_find(activity.id)?.copyWith(saved: activity.saved));
      return false;
    }
  }

  /// Registration is *not* optimistic: whether a tap becomes a seat or a
  /// waitlist place is the server's to decide, and guessing wrong here
  /// would tell someone they have a place they do not have.
  Future<ActivityRegistrationInfo?> register(
    Activity activity, {
    bool cancel = false,
  }) async {
    try {
      final info =
          await _repository.register(activity.id, cancel: cancel);
      _replace(_find(activity.id)?.copyWith(registration: info));
      return info;
    } catch (_) {
      return null;
    }
  }

  Activity? _find(int id) {
    for (final item in state.items) {
      if (item.id == id) return item;
    }
    return state.featured?.id == id ? state.featured : null;
  }

  void _replace(Activity? updated) {
    if (updated == null) return;
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == updated.id) updated else item
      ],
      featured:
          state.featured?.id == updated.id ? updated : state.featured,
    );
  }
}

final activitiesControllerProvider =
    NotifierProvider<ActivitiesController, ActivitiesState>(
        ActivitiesController.new);

/// The calendar month's density dots, refetched when the month or the
/// filters change.
final activityCalendarProvider = FutureProvider.autoDispose
    .family<List<CalendarDay>, DateTime>((ref, month) {
  final query = ref.watch(
      activitiesControllerProvider.select((state) => state.query));
  return ref
      .watch(activitiesRepositoryProvider)
      .calendar(month: month, query: query);
});

/// List or calendar, remembered across launches. A per-viewer convenience,
/// so a failure to read it just means the list.
class ViewModeController extends Notifier<ActivitiesView> {
  @override
  ActivitiesView build() {
    Future.microtask(_restore);
    return ActivitiesView.list;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_viewModeKey) == 'calendar') {
        state = ActivitiesView.calendar;
      }
    } catch (_) {
      // Stay on the list.
    }
  }

  Future<void> set(ActivitiesView view) async {
    state = view;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _viewModeKey, view == ActivitiesView.calendar ? 'calendar' : 'list');
    } catch (_) {
      // The choice still applies for this session.
    }
  }
}

final activitiesViewProvider =
    NotifierProvider<ViewModeController, ActivitiesView>(
        ViewModeController.new);
