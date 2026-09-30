import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import 'welcome_widgets.dart';

/// A published legal document.
@immutable
class LegalDocument {
  const LegalDocument({
    required this.kind,
    required this.title,
    required this.body,
    required this.version,
    this.updatedAt,
    this.languageFallback = false,
  });

  final String kind;
  final String title;
  final String body;
  final String version;
  final DateTime? updatedAt;

  /// True when the reader's language has no translation yet and they are
  /// seeing the English text.
  final bool languageFallback;

  factory LegalDocument.fromJson(Map<String, dynamic> json) => LegalDocument(
    kind: json['kind'] as String? ?? '',
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    version: json['version'] as String? ?? '',
    updatedAt: json['updated_at'] is String
        ? DateTime.tryParse(json['updated_at'] as String)?.toLocal()
        : null,
    languageFallback: json['language_fallback'] as bool? ?? false,
  );
}

/// Distinguishes "not published" from "could not load" — the first is a
/// fact about the foundation, the second is a problem with this device,
/// and they need different words.
class LegalUnavailable implements Exception {
  const LegalUnavailable();
}

final legalDocumentProvider = FutureProvider.autoDispose
    .family<LegalDocument, String>((ref, kind) async {
      final dio = ref.watch(dioProvider);
      try {
        final response = await dio.get<Map<String, dynamic>>('legal/$kind/');
        return LegalDocument.fromJson(response.data ?? const {});
      } on DioException catch (error) {
        if (error.response?.statusCode == 404) {
          throw const LegalUnavailable();
        }
        rethrow;
      }
    });

/// Terms of Use and Privacy Policy.
///
/// It renders only what the foundation has published. When nothing is
/// published it says so — it never substitutes text of its own, because
/// invented legal copy is worse than none.
class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key, required this.kind});

  /// 'terms' or 'privacy'
  final String kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final document = ref.watch(legalDocumentProvider(kind));
    final fallbackTitle = kind == 'privacy'
        ? t.welcomePrivacyPolicy
        : t.welcomeTermsOfUse;

    return Scaffold(
      backgroundColor: warmWhite,
      appBar: AppBar(
        backgroundColor: warmWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/welcome'),
          icon: const Icon(Icons.arrow_back_rounded),
          color: deepNavy,
        ),
        title: Text(
          document.asData?.value.title.isNotEmpty == true
              ? document.asData!.value.title
              : fallbackTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: deepNavy,
          ),
        ),
      ),
      body: SafeArea(
        child: switch (document) {
          AsyncData(:final value) => _body(context, t, value),
          AsyncError(:final error) => _error(context, ref, t, error),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations t,
    LegalDocument document,
  ) {
    final locale = Localizations.localeOf(context).toString();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        if (document.languageFallback) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEED9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              t.legalShownInEnglish,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF8A4B00)),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (document.updatedAt != null) ...[
          Text(
            t.legalLastUpdated(
              DateFormat.yMMMMd(locale).format(document.updatedAt!),
            ),
            style: const TextStyle(fontSize: 12.5, color: supportingText),
          ),
          const SizedBox(height: 16),
        ],
        // Rendered verbatim. Nothing here reformats, summarises or
        // abridges what the foundation published.
        SelectableText(
          document.body,
          style: const TextStyle(
            fontSize: 14.5,
            height: 1.6,
            color: Color(0xFF3E3B46),
          ),
        ),
      ],
    );
  }

  Widget _error(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations t,
    Object error,
  ) {
    final unpublished = error is LegalUnavailable;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              unpublished ? Icons.description_outlined : Icons.wifi_off_rounded,
              size: 40,
              color: supportingText,
            ),
            const SizedBox(height: 14),
            Text(
              unpublished ? t.legalUnavailableTitle : t.legalLoadFailed,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: deepNavy,
              ),
            ),
            if (unpublished) ...[
              const SizedBox(height: 6),
              Text(
                t.legalUnavailableBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: supportingText,
                ),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => ref.invalidate(legalDocumentProvider(kind)),
              style: FilledButton.styleFrom(
                backgroundColor: royalBlue,
                minimumSize: const Size(140, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(t.welcomeRetry),
            ),
          ],
        ),
      ),
    );
  }
}
