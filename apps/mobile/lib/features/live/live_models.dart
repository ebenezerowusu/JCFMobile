import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Server-authoritative event state. The app may show a provisional value
/// from timestamps but always reconciles with the server.
enum LiveStatus {
  scheduled,
  startingSoon,
  live,
  ended,
  replayProcessing,
  replayAvailable,
  cancelled,
  rescheduled,
  unavailable;

  static LiveStatus parse(String? value) => switch (value) {
        'scheduled' => LiveStatus.scheduled,
        'starting_soon' => LiveStatus.startingSoon,
        'live' => LiveStatus.live,
        'ended' => LiveStatus.ended,
        'replay_processing' => LiveStatus.replayProcessing,
        'replay_available' => LiveStatus.replayAvailable,
        'cancelled' => LiveStatus.cancelled,
        'rescheduled' => LiveStatus.rescheduled,
        _ => LiveStatus.unavailable,
      };

  bool get isBeforeStart =>
      this == LiveStatus.scheduled || this == LiveStatus.startingSoon;
}

class LiveFacilitator {
  const LiveFacilitator({
    required this.displayName,
    required this.role,
    required this.avatarUrl,
    required this.verified,
    this.id,
  });

  final String displayName;
  final String role;
  final String avatarUrl;
  final bool verified;
  final int? id;

  /// Initials stand in for a real person who has no approved portrait —
  /// a stock face is never attached to their name.
  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  factory LiveFacilitator.fromJson(Map<String, dynamic> json) =>
      LiveFacilitator(
        displayName: json['display_name'] as String? ?? '',
        role: json['role'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String? ?? '',
        verified: json['verified'] as bool? ?? false,
        id: json['id'] as int?,
      );
}

class LiveStream {
  const LiveStream({
    required this.playbackUrl,
    required this.playbackType,
    required this.dvrEnabled,
    required this.lowLatency,
    required this.captionsUrl,
    required this.pipAllowed,
  });

  final String playbackUrl;
  final String playbackType;
  final bool dvrEnabled;
  final bool lowLatency;
  final String captionsUrl;
  final bool pipAllowed;

  factory LiveStream.fromJson(Map<String, dynamic> json) => LiveStream(
        playbackUrl: json['playback_url'] as String? ?? '',
        playbackType: json['playback_type'] as String? ?? 'hls',
        dvrEnabled: json['dvr_enabled'] as bool? ?? false,
        lowLatency: json['low_latency'] as bool? ?? false,
        captionsUrl: json['captions_url'] as String? ?? '',
        pipAllowed: json['pip_allowed'] as bool? ?? false,
      );
}

class ReplayMedia {
  const ReplayMedia({
    required this.playbackUrl,
    required this.processingStatus,
    required this.thumbnailUrl,
    this.durationSeconds,
    this.captionsUrl = '',
  });

  final String playbackUrl;
  final String processingStatus;
  final String thumbnailUrl;
  final int? durationSeconds;
  final String captionsUrl;

  bool get ready => processingStatus == 'available' && playbackUrl.isNotEmpty;

  factory ReplayMedia.fromJson(Map<String, dynamic> json) => ReplayMedia(
        playbackUrl: json['playback_url'] as String? ?? '',
        processingStatus: json['processing_status'] as String? ?? 'none',
        thumbnailUrl: json['thumbnail_url'] as String? ?? '',
        durationSeconds: json['duration_seconds'] as int?,
        captionsUrl: json['captions_url'] as String? ?? '',
      );
}

class LiveChatConfig {
  const LiveChatConfig({
    required this.enabled,
    required this.visibleToGuests,
    required this.authRequiredToPost,
    required this.slowModeSeconds,
    required this.maxMessageLength,
    required this.readOnly,
  });

  final bool enabled;
  final bool visibleToGuests;
  final bool authRequiredToPost;
  final int slowModeSeconds;
  final int maxMessageLength;

  /// True when this member is muted for the session.
  final bool readOnly;

  factory LiveChatConfig.fromJson(Map<String, dynamic> json) => LiveChatConfig(
        enabled: json['enabled'] as bool? ?? false,
        visibleToGuests: json['visible_to_guests'] as bool? ?? false,
        authRequiredToPost:
            json['authentication_required_to_post'] as bool? ?? true,
        slowModeSeconds: json['slow_mode_seconds'] as int? ?? 0,
        maxMessageLength: json['max_message_length'] as int? ?? 300,
        readOnly: json['read_only'] as bool? ?? false,
      );
}

class LiveAccess {
  const LiveAccess({
    required this.allowed,
    required this.requiredTier,
    required this.signInRequired,
  });

  final bool allowed;
  final String requiredTier;
  final bool signInRequired;

  factory LiveAccess.fromJson(Map<String, dynamic> json) => LiveAccess(
        allowed: json['allowed'] as bool? ?? false,
        requiredTier: json['required_tier'] as String? ?? 'public',
        signInRequired: json['sign_in_required'] as bool? ?? false,
      );
}

class LiveEventDetail {
  const LiveEventDetail({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.posterUrl,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.language,
    required this.category,
    required this.venue,
    required this.viewerCount,
    required this.viewerCountVisible,
    required this.chat,
    required this.access,
    required this.reminderEnabled,
    required this.saved,
    required this.sharingAllowed,
    required this.canonicalUrl,
    this.facilitator,
    this.stream,
    this.replay,
    this.cancellationNote = '',
  });

  final int id;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final String posterUrl;
  final LiveStatus status;
  final DateTime startsAt;
  final DateTime endsAt;
  final String language;
  final String category;
  final String venue;
  final int viewerCount;
  final bool viewerCountVisible;
  final LiveChatConfig chat;
  final LiveAccess access;
  final bool reminderEnabled;
  final bool saved;
  final bool sharingAllowed;
  final String canonicalUrl;
  final LiveFacilitator? facilitator;
  final LiveStream? stream;
  final ReplayMedia? replay;
  final String cancellationNote;

  /// What should actually play right now, if anything.
  String? get playableUrl {
    if (status == LiveStatus.live) return stream?.playbackUrl;
    if (status == LiveStatus.replayAvailable && (replay?.ready ?? false)) {
      return replay!.playbackUrl;
    }
    return null;
  }

  bool get isReplay => status == LiveStatus.replayAvailable;

  LiveEventDetail copyWith({bool? saved, bool? reminderEnabled}) =>
      LiveEventDetail(
        id: id,
        title: title,
        shortDescription: shortDescription,
        fullDescription: fullDescription,
        posterUrl: posterUrl,
        status: status,
        startsAt: startsAt,
        endsAt: endsAt,
        language: language,
        category: category,
        venue: venue,
        viewerCount: viewerCount,
        viewerCountVisible: viewerCountVisible,
        chat: chat,
        access: access,
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        saved: saved ?? this.saved,
        sharingAllowed: sharingAllowed,
        canonicalUrl: canonicalUrl,
        facilitator: facilitator,
        stream: stream,
        replay: replay,
        cancellationNote: cancellationNote,
      );

  factory LiveEventDetail.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? obj(String key) => json[key] as Map<String, dynamic>?;
    return LiveEventDetail(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      shortDescription: json['short_description'] as String? ?? '',
      fullDescription: json['full_description'] as String? ?? '',
      posterUrl: json['poster_url'] as String? ?? '',
      status: LiveStatus.parse(json['status'] as String?),
      startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
      endsAt: DateTime.parse(json['ends_at'] as String).toLocal(),
      language: json['language'] as String? ?? '',
      category: json['category'] as String? ?? '',
      venue: json['venue'] as String? ?? '',
      viewerCount: json['viewer_count'] as int? ?? 0,
      viewerCountVisible: json['viewer_count_visible'] as bool? ?? false,
      chat: LiveChatConfig.fromJson(obj('chat') ?? const {}),
      access: LiveAccess.fromJson(obj('access') ?? const {}),
      reminderEnabled: json['reminder_enabled'] as bool? ?? false,
      saved: json['saved'] as bool? ?? false,
      sharingAllowed: json['sharing_allowed'] as bool? ?? true,
      canonicalUrl: json['canonical_url'] as String? ?? '',
      facilitator: obj('facilitator') == null
          ? null
          : LiveFacilitator.fromJson(obj('facilitator')!),
      stream: obj('stream') == null ? null : LiveStream.fromJson(obj('stream')!),
      replay:
          obj('replay') == null ? null : ReplayMedia.fromJson(obj('replay')!),
      cancellationNote: json['cancellation_note'] as String? ?? '',
    );
  }
}

class LiveChatMessage {
  const LiveChatMessage({
    required this.id,
    required this.displayName,
    required this.role,
    required this.text,
    required this.deleted,
    required this.pinned,
    required this.createdAt,
    this.contactId,
    this.pending = false,
    this.failed = false,
  });

  final int id;
  final String displayName;
  final String role; // participant | facilitator | moderator | system
  final String text;
  final bool deleted;
  final bool pinned;
  final DateTime createdAt;
  final int? contactId;

  /// Local-only flags for a message that has not been accepted yet.
  final bool pending;
  final bool failed;

  factory LiveChatMessage.fromJson(Map<String, dynamic> json) =>
      LiveChatMessage(
        id: json['id'] as int? ?? 0,
        displayName: json['display_name'] as String? ?? '',
        role: json['role'] as String? ?? 'participant',
        text: json['text'] as String? ?? '',
        deleted: json['deleted'] as bool? ?? false,
        pinned: json['pinned'] as bool? ?? false,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal() ??
                DateTime.now(),
        contactId: json['contact_id'] as int?,
      );
}

class LiveChatPage {
  const LiveChatPage(
      {required this.enabled, required this.messages, this.pinned});

  final bool enabled;
  final List<LiveChatMessage> messages;
  final LiveChatMessage? pinned;

  factory LiveChatPage.fromJson(Map<String, dynamic> json) => LiveChatPage(
        enabled: json['enabled'] as bool? ?? false,
        messages: [
          for (final row in (json['results'] as List? ?? []))
            LiveChatMessage.fromJson(row as Map<String, dynamic>)
        ],
        pinned: json['pinned'] == null
            ? null
            : LiveChatMessage.fromJson(
                json['pinned'] as Map<String, dynamic>),
      );
}

/// Thrown when chat is closed to this viewer.
class LiveChatForbidden implements Exception {
  const LiveChatForbidden();
}

class LiveEventNotFound implements Exception {
  const LiveEventNotFound();
}

class LiveRepository {
  LiveRepository(this._dio);

  final Dio _dio;

  Future<LiveEventDetail> load(int eventId) async {
    try {
      final res =
          await _dio.get<Map<String, dynamic>>('events/$eventId/live/');
      return LiveEventDetail.fromJson(res.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) throw const LiveEventNotFound();
      rethrow;
    }
  }

  /// Chat is read through a cursor, so the same contract works whether the
  /// transport is polling today or a socket later.
  Future<LiveChatPage> chat(int eventId, {int? after}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        'events/$eventId/chat/',
        queryParameters: after == null ? null : {'after': after},
      );
      return LiveChatPage.fromJson(res.data!);
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      if (code == 401 || code == 403) throw const LiveChatForbidden();
      rethrow;
    }
  }

  Future<LiveChatMessage> send(int eventId, String text) async {
    final res = await _dio.post<Map<String, dynamic>>(
        'events/$eventId/chat/', data: {'text': text});
    return LiveChatMessage.fromJson(res.data!);
  }

  Future<void> report(int eventId, int messageId) =>
      _dio.post('events/$eventId/chat/$messageId/report/');

  Future<void> block(int eventId, int contactId) =>
      _dio.post('events/$eventId/chat/block/$contactId/');

  Future<Map<String, int>> react(int eventId, String kind) async {
    final res = await _dio.post<Map<String, dynamic>>(
        'events/$eventId/reaction/', data: {'kind': kind});
    final counts = res.data?['counts'] as Map<String, dynamic>? ?? const {};
    return {for (final e in counts.entries) e.key: e.value as int};
  }

  Future<bool> setSaved(int eventId, {required bool saved}) async {
    final path = 'events/$eventId/save/';
    final res = saved
        ? await _dio.post<Map<String, dynamic>>(path)
        : await _dio.delete<Map<String, dynamic>>(path);
    return res.data?['saved'] as bool? ?? saved;
  }

  /// Heartbeat for the concurrent-viewer count. Sent once playback starts,
  /// never merely because the screen opened.
  Future<int> heartbeat(int eventId, String key) async {
    final res = await _dio.post<Map<String, dynamic>>(
        'events/$eventId/viewer-session/', data: {'key': key});
    return res.data?['viewer_count'] as int? ?? 0;
  }

  Future<void> endViewerSession(int eventId, String key) =>
      _dio.delete('events/$eventId/viewer-session/',
          queryParameters: {'key': key});
}

final liveRepositoryProvider =
    Provider<LiveRepository>((ref) => LiveRepository(ref.watch(dioProvider)));

final liveEventProvider =
    FutureProvider.family.autoDispose<LiveEventDetail, int>((ref, id) {
  return ref.watch(liveRepositoryProvider).load(id);
});
