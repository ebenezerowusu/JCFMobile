/// A lesson/teaching (mirrors the API's teaching serializers).
class Teaching {
  const Teaching({
    required this.id,
    required this.slug,
    required this.topic,
    required this.format,
    required this.language,
    required this.tier,
    required this.mediaKind,
    required this.isLocked,
    this.durationSeconds,
    this.thumbnailUrl = '',
    this.seriesSlug,
    this.description = '',
    this.youtubeUrl = '',
    this.mediaUrl = '',
  });

  final int id;
  final String slug;
  final String topic;
  final String format;
  final String language;
  final String tier; // 'general' | 'premium'
  final String mediaKind; // 'video' | 'audio'
  final bool isLocked;
  final int? durationSeconds;
  final String thumbnailUrl;
  final String? seriesSlug;

  // Detail-only fields
  final String description;
  final String youtubeUrl;
  final String mediaUrl;

  bool get isPremium => tier == 'premium';

  factory Teaching.fromJson(Map<String, dynamic> json) => Teaching(
        id: json['id'] as int,
        slug: json['slug'] as String,
        topic: json['topic'] as String,
        format: json['format'] as String? ?? '',
        language: json['language'] as String? ?? '',
        tier: json['tier'] as String? ?? 'general',
        mediaKind: json['media_kind'] as String? ?? 'video',
        isLocked: json['is_locked'] as bool? ?? false,
        durationSeconds: json['duration_seconds'] as int?,
        thumbnailUrl: json['thumbnail_url'] as String? ?? '',
        seriesSlug: json['series'] as String?,
        description: json['description'] as String? ?? '',
        youtubeUrl: json['youtube_url'] as String? ?? '',
        mediaUrl: json['media_url'] as String? ?? '',
      );
}
