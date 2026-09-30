import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Body block types the reader knows how to draw. Anything else is ignored
/// rather than crashing the article.
enum BlockType {
  paragraph,
  heading,
  subheading,
  pullQuote,
  image,
  bulletList,
  numberedList,
  divider,
  unsupported;

  static BlockType parse(String? type) => switch (type) {
        'paragraph' => BlockType.paragraph,
        'heading' => BlockType.heading,
        'subheading' => BlockType.subheading,
        'pull_quote' => BlockType.pullQuote,
        'image' => BlockType.image,
        'bullet_list' => BlockType.bulletList,
        'numbered_list' => BlockType.numberedList,
        'divider' => BlockType.divider,
        _ => BlockType.unsupported,
      };
}

class InspirationBlock {
  const InspirationBlock({
    required this.id,
    required this.type,
    required this.text,
    required this.source,
    required this.imageUrl,
    required this.altText,
    required this.caption,
    required this.items,
  });

  final int id;
  final BlockType type;
  final String text;
  final String source;
  final String imageUrl;
  final String altText;
  final String caption;
  final List<String> items;

  factory InspirationBlock.fromJson(Map<String, dynamic> json) =>
      InspirationBlock(
        id: json['id'] as int? ?? 0,
        type: BlockType.parse(json['type'] as String?),
        text: json['text'] as String? ?? '',
        source: json['source'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
        altText: json['alt_text'] as String? ?? '',
        caption: json['caption'] as String? ?? '',
        items: [
          for (final item in (json['items'] as List? ?? [])) '$item'
        ],
      );
}

class ReflectionPrompt {
  const ReflectionPrompt({
    required this.question,
    required this.guidance,
    required this.status,
  });

  final String question;
  final String guidance;
  final String status; // open | reflected

  factory ReflectionPrompt.fromJson(Map<String, dynamic> json) =>
      ReflectionPrompt(
        question: json['question'] as String? ?? '',
        guidance: json['guidance'] as String? ?? '',
        status: json['status'] as String? ?? 'open',
      );
}

class InspirationAudio {
  const InspirationAudio(
      {required this.url, required this.title, this.durationSeconds});

  final String url;
  final String title;
  final int? durationSeconds;

  factory InspirationAudio.fromJson(Map<String, dynamic> json) =>
      InspirationAudio(
        url: json['url'] as String? ?? '',
        title: json['title'] as String? ?? '',
        durationSeconds: json['duration_seconds'] as int?,
      );
}

/// A lightweight inspiration reference: related cards and previous/next.
class InspirationSummary {
  const InspirationSummary({
    required this.id,
    required this.slug,
    required this.category,
    required this.title,
    required this.readingTimeMinutes,
    required this.saved,
    this.imageUrl = '',
    this.publishedAt,
  });

  final int id;
  final String slug;
  final String category;
  final String title;
  final int readingTimeMinutes;
  final bool saved;
  final String imageUrl;
  final DateTime? publishedAt;

  factory InspirationSummary.fromJson(Map<String, dynamic> json) =>
      InspirationSummary(
        id: json['id'] as int? ?? 0,
        slug: json['slug'] as String? ?? '',
        category: json['category'] as String? ?? '',
        title: json['title'] as String? ?? '',
        readingTimeMinutes: json['reading_time_minutes'] as int? ?? 1,
        saved: json['saved'] as bool? ?? false,
        imageUrl: json['image_url'] as String? ?? '',
        publishedAt: json['published_at'] == null
            ? null
            : DateTime.tryParse(json['published_at'] as String),
      );
}

class DailyInspirationDetail {
  const DailyInspirationDetail({
    required this.id,
    required this.slug,
    required this.category,
    required this.title,
    required this.primaryQuote,
    required this.shareExcerpt,
    required this.readingTimeMinutes,
    required this.heroImageUrl,
    required this.heroAltText,
    required this.bodyBlocks,
    required this.saved,
    required this.reflected,
    required this.sharingAllowed,
    required this.canonicalUrl,
    required this.related,
    this.author,
    this.publishedAt,
    this.prompt,
    this.audio,
    this.previous,
    this.next,
  });

  final int id;
  final String slug;
  final String category;
  final String title;
  final String primaryQuote;
  final String shareExcerpt;
  final int readingTimeMinutes;
  final String heroImageUrl;
  final String heroAltText;
  final List<InspirationBlock> bodyBlocks;
  final bool saved;
  final bool reflected;
  final bool sharingAllowed;
  final String canonicalUrl;
  final List<InspirationSummary> related;

  /// Not every inspiration is attributed.
  final String? author;
  final DateTime? publishedAt;
  final ReflectionPrompt? prompt;
  final InspirationAudio? audio;
  final InspirationSummary? previous;
  final InspirationSummary? next;

  DailyInspirationDetail copyWith({bool? saved, bool? reflected}) =>
      DailyInspirationDetail(
        id: id,
        slug: slug,
        category: category,
        title: title,
        primaryQuote: primaryQuote,
        shareExcerpt: shareExcerpt,
        readingTimeMinutes: readingTimeMinutes,
        heroImageUrl: heroImageUrl,
        heroAltText: heroAltText,
        bodyBlocks: bodyBlocks,
        saved: saved ?? this.saved,
        reflected: reflected ?? this.reflected,
        sharingAllowed: sharingAllowed,
        canonicalUrl: canonicalUrl,
        related: related,
        author: author,
        publishedAt: publishedAt,
        prompt: prompt,
        audio: audio,
        previous: previous,
        next: next,
      );

  factory DailyInspirationDetail.fromJson(Map<String, dynamic> json) {
    final hero = json['hero_image'] as Map<String, dynamic>? ?? const {};
    final prompt = json['reflection_prompt'] as Map<String, dynamic>?;
    final audio = json['audio'] as Map<String, dynamic>?;
    final previous = json['previous_inspiration'] as Map<String, dynamic>?;
    final next = json['next_inspiration'] as Map<String, dynamic>?;
    return DailyInspirationDetail(
      id: json['id'] as int? ?? 0,
      slug: json['slug'] as String? ?? '',
      category: json['category'] as String? ?? '',
      title: json['title'] as String? ?? '',
      primaryQuote: json['primary_quote'] as String? ?? '',
      shareExcerpt: json['share_excerpt'] as String? ?? '',
      readingTimeMinutes: json['reading_time_minutes'] as int? ?? 1,
      heroImageUrl: hero['url'] as String? ?? '',
      heroAltText: hero['alt_text'] as String? ?? '',
      bodyBlocks: [
        for (final row in (json['body_blocks'] as List? ?? []))
          InspirationBlock.fromJson(row as Map<String, dynamic>)
      ],
      saved: json['saved'] as bool? ?? false,
      reflected: json['reflected'] as bool? ?? false,
      sharingAllowed: json['sharing_allowed'] as bool? ?? true,
      canonicalUrl: json['canonical_url'] as String? ?? '',
      related: [
        for (final row in (json['related_inspirations'] as List? ?? []))
          InspirationSummary.fromJson(row as Map<String, dynamic>)
      ],
      author: (json['author'] as String?)?.trim().isEmpty ?? true
          ? null
          : json['author'] as String,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.tryParse(json['published_at'] as String),
      prompt: prompt == null ? null : ReflectionPrompt.fromJson(prompt),
      audio: audio == null ? null : InspirationAudio.fromJson(audio),
      previous:
          previous == null ? null : InspirationSummary.fromJson(previous),
      next: next == null ? null : InspirationSummary.fromJson(next),
    );
  }
}

/// Thrown when a shared link points at content that no longer exists.
class InspirationNotFound implements Exception {
  const InspirationNotFound();
}

class InspirationDetailRepository {
  InspirationDetailRepository(this._dio);

  final Dio _dio;

  Future<DailyInspirationDetail> load(String identifier) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
          'inspirations/$identifier/');
      return DailyInspirationDetail.fromJson(res.data!);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 404 || status == 410) throw const InspirationNotFound();
      rethrow;
    }
  }

  Future<bool> setSaved(String identifier, {required bool saved}) async {
    final path = 'inspirations/$identifier/save/';
    final res = saved
        ? await _dio.post<Map<String, dynamic>>(path)
        : await _dio.delete<Map<String, dynamic>>(path);
    return res.data?['saved'] as bool? ?? saved;
  }

  Future<bool> setReflected(String identifier, {required bool reflected}) async {
    final path = 'inspirations/$identifier/reflection/';
    final res = reflected
        ? await _dio.post<Map<String, dynamic>>(path)
        : await _dio.delete<Map<String, dynamic>>(path);
    return res.data?['reflected'] as bool? ?? reflected;
  }
}

final inspirationDetailRepositoryProvider =
    Provider<InspirationDetailRepository>(
        (ref) => InspirationDetailRepository(ref.watch(dioProvider)));

/// The detail payload for one inspiration, keyed by id or slug.
final inspirationDetailProvider = FutureProvider.family
    .autoDispose<DailyInspirationDetail, String>((ref, identifier) {
  return ref.watch(inspirationDetailRepositoryProvider).load(identifier);
});
