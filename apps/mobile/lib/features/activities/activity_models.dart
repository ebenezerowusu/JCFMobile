import 'package:flutter/foundation.dart';

/// Where an activity happens. Hybrid is genuinely both, and the server
/// returns it under the Online *and* the In person chip.
enum ActivityFormat { online, inPerson, hybrid }

ActivityFormat _formatFrom(String? raw) => switch (raw) {
      'online' => ActivityFormat.online,
      'hybrid' => ActivityFormat.hybrid,
      _ => ActivityFormat.inPerson,
    };

/// Why registration is or is not possible. The server decides; the app only
/// renders. Anything unrecognised reads as `notRequired`, which shows no
/// button at all rather than one that cannot work.
enum RegistrationState {
  notRequired,
  opensLater,
  open,
  full,
  waitlist,
  closed,
  cancelled,
  external,
}

RegistrationState _registrationStateFrom(String? raw) => switch (raw) {
      'opens_later' => RegistrationState.opensLater,
      'open' => RegistrationState.open,
      'full' => RegistrationState.full,
      'waitlist' => RegistrationState.waitlist,
      'closed' => RegistrationState.closed,
      'cancelled' => RegistrationState.cancelled,
      'external' => RegistrationState.external,
      _ => RegistrationState.notRequired,
    };

/// The caller's own place at an activity, if any.
enum MyRegistration { none, registered, waitlisted, cancelled }

MyRegistration _myRegistrationFrom(String? raw) => switch (raw) {
      'registered' => MyRegistration.registered,
      'waitlisted' => MyRegistration.waitlisted,
      'cancelled' => MyRegistration.cancelled,
      _ => MyRegistration.none,
    };

@immutable
class ActivityAccess {
  const ActivityAccess({
    required this.allowed,
    required this.signInRequired,
    required this.reason,
    required this.requiredAudience,
  });

  final bool allowed;
  final bool signInRequired;

  /// '' | 'sign_in' | 'members_only' | 'students_only'
  final String reason;
  final String requiredAudience;

  factory ActivityAccess.fromJson(Map<String, dynamic>? json) =>
      ActivityAccess(
        allowed: json?['allowed'] as bool? ?? true,
        signInRequired: json?['sign_in_required'] as bool? ?? false,
        reason: json?['reason'] as String? ?? '',
        requiredAudience: json?['required_audience'] as String? ?? 'public',
      );
}

@immutable
class ActivityRegistrationInfo {
  const ActivityRegistrationInfo({
    required this.required_,
    required this.state,
    required this.mine,
    this.capacity,
    this.seatsLeft,
    this.opensAt,
    this.closesAt,
    this.waitlistEnabled = false,
    this.externalUrl = '',
  });

  // `required` is a Dart keyword in this position, hence the trailing _.
  final bool required_;
  final RegistrationState state;
  final MyRegistration mine;
  final int? capacity;
  final int? seatsLeft;
  final DateTime? opensAt;
  final DateTime? closesAt;
  final bool waitlistEnabled;
  final String externalUrl;

  /// True when only a handful of places remain — the card says so instead of
  /// printing a number nobody can act on.
  bool get nearlyFull =>
      seatsLeft != null && seatsLeft! > 0 && seatsLeft! <= 5;

  factory ActivityRegistrationInfo.fromJson(Map<String, dynamic>? json) =>
      ActivityRegistrationInfo(
        required_: json?['required'] as bool? ?? false,
        state: _registrationStateFrom(json?['state'] as String?),
        mine: _myRegistrationFrom(json?['my_status'] as String?),
        capacity: json?['capacity'] as int?,
        seatsLeft: json?['seats_left'] as int?,
        opensAt: _parseDate(json?['opens_at']),
        closesAt: _parseDate(json?['closes_at']),
        waitlistEnabled: json?['waitlist_enabled'] as bool? ?? false,
        externalUrl: json?['external_url'] as String? ?? '',
      );

  ActivityRegistrationInfo copyWith({
    RegistrationState? state,
    MyRegistration? mine,
    int? seatsLeft,
  }) =>
      ActivityRegistrationInfo(
        required_: required_,
        state: state ?? this.state,
        mine: mine ?? this.mine,
        capacity: capacity,
        seatsLeft: seatsLeft ?? this.seatsLeft,
        opensAt: opensAt,
        closesAt: closesAt,
        waitlistEnabled: waitlistEnabled,
        externalUrl: externalUrl,
      );
}

@immutable
class ActivityFee {
  const ActivityFee({
    required this.free,
    required this.display,
  });

  final bool free;
  final String display;

  factory ActivityFee.fromJson(Map<String, dynamic>? json) => ActivityFee(
        free: json?['free'] as bool? ?? true,
        display: json?['display'] as String? ?? '',
      );
}

@immutable
class ActivityFacilitator {
  const ActivityFacilitator({
    required this.displayName,
    required this.role,
    required this.avatarUrl,
  });

  final String displayName;
  final String role;
  final String avatarUrl;

  /// Up to two initials, for when no approved portrait exists.
  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  static ActivityFacilitator? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final name = json['display_name'] as String? ?? '';
    if (name.isEmpty) return null;
    return ActivityFacilitator(
      displayName: name,
      role: json['role'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
    );
  }
}

/// Where tapping the card goes. A stable identifier, not a route: the app
/// owns its own paths.
@immutable
class ActivityDestination {
  const ActivityDestination({required this.type, required this.eventId});

  final String type; // live | activity
  final int eventId;

  factory ActivityDestination.fromJson(Map<String, dynamic>? json, int id) =>
      ActivityDestination(
        type: json?['type'] as String? ?? 'activity',
        eventId: json?['event_id'] as int? ?? id,
      );
}

DateTime? _parseDate(Object? raw) =>
    raw is String ? DateTime.parse(raw).toLocal() : null;

/// One row of the Upcoming Activities list (designs 37–41).
@immutable
class Activity {
  const Activity({
    required this.id,
    required this.kind,
    required this.activityType,
    required this.activityTypeLabel,
    required this.title,
    required this.summary,
    required this.startsAt,
    required this.endsAt,
    required this.allDay,
    required this.durationMinutes,
    required this.format,
    required this.formatLabel,
    required this.locationLine,
    required this.language,
    required this.imageUrl,
    required this.imageKey,
    required this.access,
    required this.registration,
    required this.fee,
    required this.destination,
    this.facilitator,
    this.reminderSet = false,
    this.saved = false,
    this.cancelled = false,
    this.rescheduledNote = '',
    this.isLiveNow = false,
    this.startingSoon = false,
    this.featuredBlurb = '',
  });

  final int id;
  final String kind; // live | practice | gathering
  final String activityType;
  final String activityTypeLabel;
  final String title;
  final String summary;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool allDay;
  final int durationMinutes;
  final ActivityFormat format;
  final String formatLabel;
  final String locationLine;
  final String language;
  final String imageUrl;
  final String imageKey;
  final ActivityAccess access;
  final ActivityRegistrationInfo registration;
  final ActivityFee fee;
  final ActivityDestination destination;
  final ActivityFacilitator? facilitator;
  final bool reminderSet;
  final bool saved;
  final bool cancelled;
  final String rescheduledNote;
  final bool isLiveNow;
  final bool startingSoon;
  final String featuredBlurb;

  /// The local calendar day this activity belongs to — the key the list
  /// groups by, so a 23:30 sitting stays on its own evening.
  DateTime get localDay =>
      DateTime(startsAt.year, startsAt.month, startsAt.day);

  bool get isOnline =>
      format == ActivityFormat.online || format == ActivityFormat.hybrid;

  bool get isInPerson =>
      format == ActivityFormat.inPerson || format == ActivityFormat.hybrid;

  factory Activity.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    return Activity(
      id: id,
      kind: json['kind'] as String? ?? 'gathering',
      activityType: json['activity_type'] as String? ?? 'other',
      activityTypeLabel: json['activity_type_label'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
      endsAt: DateTime.parse(
              (json['ends_at'] ?? json['starts_at']) as String)
          .toLocal(),
      allDay: json['all_day'] as bool? ?? false,
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      format: _formatFrom(json['format'] as String?),
      formatLabel: json['format_label'] as String? ?? '',
      locationLine: json['location_line'] as String? ?? '',
      language: json['language'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      imageKey: json['image_key'] as String? ?? '',
      access: ActivityAccess.fromJson(
          json['access'] as Map<String, dynamic>?),
      registration: ActivityRegistrationInfo.fromJson(
          json['registration'] as Map<String, dynamic>?),
      fee: ActivityFee.fromJson(json['fee'] as Map<String, dynamic>?),
      destination: ActivityDestination.fromJson(
          json['destination'] as Map<String, dynamic>?, id),
      facilitator: ActivityFacilitator.fromJson(
          json['facilitator'] as Map<String, dynamic>?),
      reminderSet: json['reminder_set'] as bool? ?? false,
      saved: json['saved'] as bool? ?? false,
      cancelled: json['cancelled'] as bool? ?? false,
      rescheduledNote: json['rescheduled_note'] as String? ?? '',
      isLiveNow: json['is_live_now'] as bool? ?? false,
      startingSoon: json['starting_soon'] as bool? ?? false,
      featuredBlurb: json['featured_blurb'] as String? ?? '',
    );
  }

  Activity copyWith({
    bool? reminderSet,
    bool? saved,
    ActivityRegistrationInfo? registration,
  }) =>
      Activity(
        id: id,
        kind: kind,
        activityType: activityType,
        activityTypeLabel: activityTypeLabel,
        title: title,
        summary: summary,
        startsAt: startsAt,
        endsAt: endsAt,
        allDay: allDay,
        durationMinutes: durationMinutes,
        format: format,
        formatLabel: formatLabel,
        locationLine: locationLine,
        language: language,
        imageUrl: imageUrl,
        imageKey: imageKey,
        access: access,
        registration: registration ?? this.registration,
        fee: fee,
        destination: destination,
        facilitator: facilitator,
        reminderSet: reminderSet ?? this.reminderSet,
        saved: saved ?? this.saved,
        cancelled: cancelled,
        rescheduledNote: rescheduledNote,
        isLiveNow: isLiveNow,
        startingSoon: startingSoon,
        featuredBlurb: featuredBlurb,
      );
}

/// One option in the advanced filter sheet, with how many activities in the
/// current window carry it.
@immutable
class FilterFacet {
  const FilterFacet({
    required this.value,
    required this.label,
    required this.count,
  });

  final String value;
  final String label;
  final int count;

  factory FilterFacet.fromJson(Map<String, dynamic> json) => FilterFacet(
        value: json['value'] as String,
        label: json['label'] as String? ?? json['value'] as String,
        count: json['count'] as int? ?? 0,
      );
}

@immutable
class AvailableFilters {
  const AvailableFilters({
    this.types = const [],
    this.languages = const [],
    this.formats = const [],
  });

  final List<FilterFacet> types;
  final List<FilterFacet> languages;
  final List<FilterFacet> formats;

  bool get isEmpty =>
      types.isEmpty && languages.isEmpty && formats.isEmpty;

  static List<FilterFacet> _list(Object? raw) => [
        for (final row in (raw as List? ?? []))
          FilterFacet.fromJson(row as Map<String, dynamic>)
      ];

  factory AvailableFilters.fromJson(Map<String, dynamic>? json) =>
      AvailableFilters(
        types: _list(json?['types']),
        languages: _list(json?['languages']),
        formats: _list(json?['formats']),
      );
}

/// One page of the browse list.
@immutable
class ActivityPage {
  const ActivityPage({
    required this.results,
    required this.serverTime,
    this.nextCursor,
    this.featured,
    this.availableFilters = const AvailableFilters(),
  });

  final List<Activity> results;
  final DateTime serverTime;
  final String? nextCursor;
  final Activity? featured;
  final AvailableFilters availableFilters;

  factory ActivityPage.fromJson(Map<String, dynamic> json) {
    final featuredJson = json['featured_activity'] as Map<String, dynamic>?;
    return ActivityPage(
      results: [
        for (final row in (json['results'] as List? ?? []))
          Activity.fromJson(row as Map<String, dynamic>)
      ],
      serverTime: json['server_time'] is String
          ? DateTime.parse(json['server_time'] as String).toLocal()
          : DateTime.now(),
      nextCursor: json['next_cursor'] as String?,
      featured:
          featuredJson == null ? null : Activity.fromJson(featuredJson),
      availableFilters: AvailableFilters.fromJson(
          json['available_filters'] as Map<String, dynamic>?),
    );
  }
}

/// A day with something on it, for the calendar view's density dots.
@immutable
class CalendarDay {
  const CalendarDay({
    required this.date,
    required this.count,
    required this.hasLive,
  });

  final DateTime date;
  final int count;
  final bool hasLive;

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    final parts = (json['date'] as String).split('-');
    return CalendarDay(
      date: DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])),
      count: json['count'] as int? ?? 0,
      hasLive: json['has_live'] as bool? ?? false,
    );
  }
}

/// The four chips above the list. `all` is the default and is never sent.
enum PrimaryFilter { all, live, online, inPerson }

extension PrimaryFilterWire on PrimaryFilter {
  String get wire => switch (this) {
        PrimaryFilter.all => 'all',
        PrimaryFilter.live => 'live',
        PrimaryFilter.online => 'online',
        PrimaryFilter.inPerson => 'in_person',
      };
}

enum FeeFilter { any, free, paid }

/// Everything that narrows the list. Held as one value so a change can reset
/// the cursor in a single place — a filter change with a stale cursor is the
/// classic way to lose the first page of results.
@immutable
class ActivityQuery {
  const ActivityQuery({
    this.primary = PrimaryFilter.all,
    this.types = const {},
    this.languages = const {},
    this.fee = FeeFilter.any,
    this.openToMeOnly = false,
    this.search = '',
    this.from,
    this.to,
  });

  final PrimaryFilter primary;
  final Set<String> types;
  final Set<String> languages;
  final FeeFilter fee;
  final bool openToMeOnly;
  final String search;
  final DateTime? from;
  final DateTime? to;

  /// How many advanced filters are on — the badge on the filter button.
  int get advancedCount =>
      types.length +
      languages.length +
      (fee == FeeFilter.any ? 0 : 1) +
      (openToMeOnly ? 1 : 0);

  bool get hasAnyFilter =>
      primary != PrimaryFilter.all ||
      advancedCount > 0 ||
      search.isNotEmpty;

  ActivityQuery copyWith({
    PrimaryFilter? primary,
    Set<String>? types,
    Set<String>? languages,
    FeeFilter? fee,
    bool? openToMeOnly,
    String? search,
    DateTime? from,
    DateTime? to,
    bool clearDates = false,
  }) =>
      ActivityQuery(
        primary: primary ?? this.primary,
        types: types ?? this.types,
        languages: languages ?? this.languages,
        fee: fee ?? this.fee,
        openToMeOnly: openToMeOnly ?? this.openToMeOnly,
        search: search ?? this.search,
        from: clearDates ? null : (from ?? this.from),
        to: clearDates ? null : (to ?? this.to),
      );

  /// Only the advanced groups — used by the filter sheet's Clear all.
  ActivityQuery clearedAdvanced() => copyWith(
        types: const {},
        languages: const {},
        fee: FeeFilter.any,
        openToMeOnly: false,
      );

  static String _day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Map<String, String> toParams() => {
        if (primary != PrimaryFilter.all) 'filter': primary.wire,
        if (types.isNotEmpty) 'types': types.join(','),
        if (languages.isNotEmpty) 'languages': languages.join(','),
        if (fee == FeeFilter.free) 'fee': 'free',
        if (fee == FeeFilter.paid) 'fee': 'paid',
        if (openToMeOnly) 'access': 'open_to_me',
        if (search.trim().isNotEmpty) 'q': search.trim(),
        if (from != null) 'from': _day(from!),
        if (to != null) 'to': _day(to!),
      };

  @override
  bool operator ==(Object other) =>
      other is ActivityQuery &&
      other.primary == primary &&
      setEquals(other.types, types) &&
      setEquals(other.languages, languages) &&
      other.fee == fee &&
      other.openToMeOnly == openToMeOnly &&
      other.search == search &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(
        primary,
        Object.hashAllUnordered(types),
        Object.hashAllUnordered(languages),
        fee,
        openToMeOnly,
        search,
        from,
        to,
      );
}
