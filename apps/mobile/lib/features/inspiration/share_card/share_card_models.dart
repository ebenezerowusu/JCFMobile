import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../inspiration_detail_repository.dart';

const _assetRoot = 'assets/images/daily_inspiration_share_card';

enum ShareCardFormat {
  square,
  story;

  /// Export pixel size; the preview uses the same ratio at screen scale.
  Size get exportSize => switch (this) {
        ShareCardFormat.square => const Size(1080, 1080),
        ShareCardFormat.story => const Size(1080, 1920),
      };

  double get aspectRatio => switch (this) {
        ShareCardFormat.square => 1,
        ShareCardFormat.story => 9 / 16,
      };

  String get id => name;
}

enum ShareCardTextAlignment {
  start,
  center,
  end;

  /// Resolved through Directionality, so RTL mirrors automatically.
  TextAlign get textAlign => switch (this) {
        ShareCardTextAlignment.start => TextAlign.start,
        ShareCardTextAlignment.center => TextAlign.center,
        ShareCardTextAlignment.end => TextAlign.end,
      };

  CrossAxisAlignment get crossAxis => switch (this) {
        ShareCardTextAlignment.start => CrossAxisAlignment.start,
        ShareCardTextAlignment.center => CrossAxisAlignment.center,
        ShareCardTextAlignment.end => CrossAxisAlignment.end,
      };
}

enum ShareCardTextColorMode { light, dark }

enum ShareCardTextSize {
  small,
  medium,
  large;

  /// Export font size in px for the excerpt, per the design's ranges.
  double quoteSize(ShareCardFormat format) => switch ((this, format)) {
        (ShareCardTextSize.small, ShareCardFormat.square) => 48,
        (ShareCardTextSize.medium, ShareCardFormat.square) => 60,
        (ShareCardTextSize.large, ShareCardFormat.square) => 72,
        (ShareCardTextSize.small, ShareCardFormat.story) => 52,
        (ShareCardTextSize.medium, ShareCardFormat.story) => 64,
        (ShareCardTextSize.large, ShareCardFormat.story) => 78,
      };
}

class ShareCardTemplate {
  const ShareCardTemplate({
    required this.id,
    required this.name,
    required this.recommendedTextColor,
    required this.formats,
    required this.enabled,
  });

  final String id;
  final String name;
  final ShareCardTextColorMode recommendedTextColor;
  final List<ShareCardFormat> formats;
  final bool enabled;

  bool supports(ShareCardFormat format) => enabled && formats.contains(format);

  /// A template is only offered in a format it has real artwork for — a
  /// square asset is never stretched into a story canvas.
  String? assetFor(ShareCardFormat format) {
    if (!supports(format)) return null;
    return '$_assetRoot/daily_inspiration_share_card_${id}_${format.id}.webp';
  }

  factory ShareCardTemplate.fromJson(Map<String, dynamic> json) =>
      ShareCardTemplate(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        recommendedTextColor:
            (json['recommended_text_color'] as String?) == 'dark'
                ? ShareCardTextColorMode.dark
                : ShareCardTextColorMode.light,
        formats: [
          for (final f in (json['formats'] as List? ?? []))
            if (f == 'story')
              ShareCardFormat.story
            else if (f == 'square')
              ShareCardFormat.square
        ],
        enabled: json['enabled'] as bool? ?? true,
      );
}

class ShareCardData {
  const ShareCardData({
    required this.inspirationId,
    required this.slug,
    required this.shareExcerpt,
    required this.canonicalUrl,
    required this.sharingAllowed,
    required this.defaultTemplateId,
    required this.templates,
    required this.websiteLabel,
    this.author,
    this.source,
  });

  final int inspirationId;
  final String slug;
  final String shareExcerpt;
  final String canonicalUrl;
  final bool sharingAllowed;
  final String defaultTemplateId;
  final List<ShareCardTemplate> templates;
  final String websiteLabel;
  final String? author;
  final String? source;

  bool get hasSource =>
      (author?.trim().isNotEmpty ?? false) ||
      (source?.trim().isNotEmpty ?? false);

  String get sourceLabel => (author?.trim().isNotEmpty ?? false)
      ? author!.trim()
      : (source?.trim() ?? '');

  ShareCardTemplate templateById(String id) => templates.firstWhere(
        (t) => t.id == id,
        orElse: () => templates.isEmpty
            ? const ShareCardTemplate(
                id: 'cosmic',
                name: 'Cosmic',
                recommendedTextColor: ShareCardTextColorMode.light,
                formats: [ShareCardFormat.square, ShareCardFormat.story],
                enabled: true)
            : templates.first,
      );

  factory ShareCardData.fromJson(Map<String, dynamic> json) => ShareCardData(
        inspirationId: json['inspiration_id'] as int? ?? 0,
        slug: json['slug'] as String? ?? '',
        shareExcerpt: json['share_excerpt'] as String? ?? '',
        canonicalUrl: json['canonical_url'] as String? ?? '',
        sharingAllowed: json['sharing_allowed'] as bool? ?? true,
        defaultTemplateId: json['default_template_id'] as String? ?? 'cosmic',
        templates: [
          for (final row in (json['templates'] as List? ?? []))
            ShareCardTemplate.fromJson(row as Map<String, dynamic>)
        ],
        websiteLabel: json['official_website_label'] as String? ?? '',
        author: json['author'] as String?,
        source: json['source'] as String?,
      );
}

/// The composer's current settings. Immutable; every control returns a copy.
class ShareCardConfiguration {
  const ShareCardConfiguration({
    required this.format,
    required this.templateId,
    required this.alignment,
    required this.textColor,
    required this.textSize,
    required this.showLogo,
    required this.showSource,
    required this.showWebsite,
  });

  final ShareCardFormat format;
  final String templateId;
  final ShareCardTextAlignment alignment;
  final ShareCardTextColorMode textColor;
  final ShareCardTextSize textSize;
  final bool showLogo;
  final bool showSource;
  final bool showWebsite;

  static ShareCardConfiguration defaults(ShareCardData data) {
    final template = data.templateById(data.defaultTemplateId);
    return ShareCardConfiguration(
      format: ShareCardFormat.square,
      templateId: template.id,
      alignment: ShareCardTextAlignment.center,
      textColor: template.recommendedTextColor,
      textSize: ShareCardTextSize.medium,
      showLogo: true,
      showSource: data.hasSource,
      showWebsite: data.websiteLabel.isNotEmpty,
    );
  }

  ShareCardConfiguration copyWith({
    ShareCardFormat? format,
    String? templateId,
    ShareCardTextAlignment? alignment,
    ShareCardTextColorMode? textColor,
    ShareCardTextSize? textSize,
    bool? showLogo,
    bool? showSource,
    bool? showWebsite,
  }) =>
      ShareCardConfiguration(
        format: format ?? this.format,
        templateId: templateId ?? this.templateId,
        alignment: alignment ?? this.alignment,
        textColor: textColor ?? this.textColor,
        textSize: textSize ?? this.textSize,
        showLogo: showLogo ?? this.showLogo,
        showSource: showSource ?? this.showSource,
        showWebsite: showWebsite ?? this.showWebsite,
      );

  bool matchesDefaults(ShareCardData data) {
    final d = defaults(data);
    return format == d.format &&
        templateId == d.templateId &&
        alignment == d.alignment &&
        textColor == d.textColor &&
        textSize == d.textSize &&
        showLogo == d.showLogo &&
        showSource == d.showSource &&
        showWebsite == d.showWebsite;
  }
}

class ShareCardRepository {
  ShareCardRepository(this._dio);

  final Dio _dio;

  Future<ShareCardData> load(String identifier) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
          'inspirations/$identifier/share-data/');
      return ShareCardData.fromJson(res.data!);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 404 || status == 410) throw const InspirationNotFound();
      rethrow;
    }
  }
}

final shareCardRepositoryProvider = Provider<ShareCardRepository>(
    (ref) => ShareCardRepository(ref.watch(dioProvider)));

final shareCardDataProvider =
    FutureProvider.family.autoDispose<ShareCardData, String>((ref, id) {
  return ref.watch(shareCardRepositoryProvider).load(id);
});
