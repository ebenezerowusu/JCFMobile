import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../core/launch.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../home/member_home_widgets.dart' show MemberImage;
import 'inspiration_detail_repository.dart';
import 'inspiration_share_sheet.dart';

const _sub = Color(0xFF667085);
const _ink = Color(0xFF172033);
const _navy = Color(0xFF102454);
const _gold = Color(0xFFE9A33A);
const _divider = Color(0xFFE4E7EC);
const _assets = 'assets/images/daily_inspiration_detail';

/// Daily Inspiration detail: a focused reading route. Public to read; save
/// and reflection require a member session.
class InspirationDetailScreen extends ConsumerStatefulWidget {
  const InspirationDetailScreen({super.key, required this.identifier});

  /// Either the numeric id or the slug — deep links use the slug.
  final String identifier;

  @override
  ConsumerState<InspirationDetailScreen> createState() =>
      _InspirationDetailScreenState();
}

class _InspirationDetailScreenState
    extends ConsumerState<InspirationDetailScreen> {
  final _scroll = ScrollController();

  /// Local overrides so save/reflect update instantly without refetching the
  /// whole article; cleared when the payload reloads.
  bool? _savedOverride;
  bool? _reflectedOverride;
  bool _busy = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _toggleSave(DailyInspirationDetail detail) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (!ref.read(isLoggedInProvider)) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.signInToSave),
          action: SnackBarAction(
            label: t.signIn,
            onPressed: () => context.push('/login'),
          ),
        ),
      );
      return;
    }
    final next = !(_savedOverride ?? detail.saved);
    setState(() {
      _savedOverride = next;
      _busy = true;
    });
    try {
      final result = await ref
          .read(inspirationDetailRepositoryProvider)
          .setSaved(widget.identifier, saved: next);
      if (mounted) setState(() => _savedOverride = result);
    } catch (_) {
      // Roll the optimistic change back and say so.
      if (mounted) setState(() => _savedOverride = !next);
      messenger.showSnackBar(SnackBar(content: Text(t.genericError)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleReflected(DailyInspirationDetail detail) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (!ref.read(isLoggedInProvider)) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.signInToReflect),
          action: SnackBarAction(
            label: t.signIn,
            onPressed: () => context.push('/login'),
          ),
        ),
      );
      return;
    }
    final next = !(_reflectedOverride ?? detail.reflected);
    setState(() {
      _reflectedOverride = next;
      _busy = true;
    });
    try {
      final result = await ref
          .read(inspirationDetailRepositoryProvider)
          .setReflected(widget.identifier, reflected: next);
      if (mounted) setState(() => _reflectedOverride = result);
    } catch (_) {
      if (mounted) setState(() => _reflectedOverride = !next);
      messenger.showSnackBar(SnackBar(content: Text(t.genericError)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _open(String slug) {
    // Replace rather than push, so browsing related items cannot grow the
    // stack without bound.
    context.pushReplacement('/inspirations/$slug');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final async = ref.watch(inspirationDetailProvider(widget.identifier));

    // Checked explicitly rather than with `when`: an error that arrives
    // while the provider is still loading is reported as AsyncLoading
    // carrying an error, which `when` would route back to the skeleton.
    final detail = async.asData?.value;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F5),
      body: detail != null
          ? _buildArticle(context, t, detail)
          : async.hasError
          ? InspirationDetailError(
              notFound: async.error is InspirationNotFound,
              onRetry: () =>
                  ref.invalidate(inspirationDetailProvider(widget.identifier)),
            )
          : const InspirationDetailSkeleton(),
    );
  }

  Widget _buildArticle(
    BuildContext context,
    AppLocalizations t,
    DailyInspirationDetail detail,
  ) {
    final saved = _savedOverride ?? detail.saved;
    final reflected = _reflectedOverride ?? detail.reflected;
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 600 ? (width - 560) / 2 : 20.0;
    final locale = Localizations.localeOf(context).toString();

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        _DetailAppBar(
          detail: detail,
          saved: saved,
          busy: _busy,
          onSave: () => _toggleSave(detail),
          onShare: () => showInspirationShareSheet(context, detail),
        ),
        SliverToBoxAdapter(
          child: _HeroBlock(detail: detail, locale: locale),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 8),
          sliver: SliverList.builder(
            itemCount: detail.bodyBlocks.length,
            itemBuilder: (context, i) => _Block(block: detail.bodyBlocks[i]),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 32),
          sliver: SliverList.list(
            children: [
              if (detail.audio case final audio?) ...[
                _AudioRow(audio: audio),
                const SizedBox(height: 24),
              ],
              if (detail.prompt case final prompt?) ...[
                ReflectionPromptCard(
                  prompt: prompt,
                  reflected: reflected,
                  busy: _busy,
                  onReflect: () => _toggleReflected(detail),
                  onSave: () => _toggleSave(detail),
                  saved: saved,
                  onShare: detail.sharingAllowed
                      ? () => showInspirationShareSheet(context, detail)
                      : null,
                ),
                const SizedBox(height: 28),
              ],
              if (detail.related.isNotEmpty) ...[
                Text(
                  t.continueReflecting,
                  style: const TextStyle(
                    color: _ink,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height:
                      208 +
                      (MediaQuery.textScalerOf(context).scale(14) / 14 - 1) *
                          120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: detail.related.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => SizedBox(
                      // The next card peeks, showing the row scrolls.
                      width: width * 0.62,
                      child: RelatedInspirationCard(
                        summary: detail.related[i],
                        fallbackAsset: i.isEven
                            ? '$_assets/daily_inspiration_related_path.webp'
                            : '$_assets/daily_inspiration_related_strength.webp',
                        onTap: () => _open(detail.related[i].slug),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
              ],
              _EndActions(
                detail: detail,
                onOpen: _open,
                onHome: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Collapsing app bar: transparent over the hero, solid once scrolled.
class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({
    required this.detail,
    required this.saved,
    required this.busy,
    required this.onSave,
    required this.onShare,
  });

  final DailyInspirationDetail detail;
  final bool saved;
  final bool busy;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFFF8F8F5),
      surfaceTintColor: Colors.transparent,
      foregroundColor: _ink,
      elevation: 0,
      scrolledUnderElevation: 1,
      shape: const Border(bottom: BorderSide(color: _divider, width: 0.6)),
      title: Text(
        t.dailyInspiration,
        style: const TextStyle(
          color: _ink,
          fontFamily: JcfTypography.bodyFamily,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        Semantics(
          button: true,
          label: saved ? t.savedLabel2 : t.saveForLater,
          toggled: saved,
          child: IconButton(
            onPressed: busy ? null : onSave,
            icon: Icon(
              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: saved ? JcfColors.skyPrimary : _ink,
            ),
          ),
        ),
        if (detail.sharingAllowed)
          Semantics(
            button: true,
            label: t.shareLabel,
            child: IconButton(
              onPressed: onShare,
              icon: const Icon(Icons.share_rounded, color: _ink),
            ),
          ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: _ink),
          onSelected: (value) {
            if (value == 'browser' && detail.canonicalUrl.isNotEmpty) {
              openExternalUrl(detail.canonicalUrl);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'browser', child: Text(t.openInBrowser)),
          ],
        ),
      ],
    );
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({required this.detail, required this.locale});

  final DailyInspirationDetail detail;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final published = detail.publishedAt;
    final meta = [
      if (published != null)
        DateFormat('d MMMM yyyy', locale).format(published),
      t.readingTime(detail.readingTimeMinutes),
    ].join('  ·  ');

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MemberImage(
            url: detail.heroImageUrl,
            asset: '$_assets/daily_inspiration_detail_hero.webp',
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).width * 9 / 16,
            semanticLabel: detail.heroAltText.isEmpty
                ? null
                : detail.heroAltText,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xF2102454),
                  Color(0x99102454),
                  Colors.transparent,
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: SingleChildScrollView(
              reverse: true,
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (detail.category.isEmpty
                            ? t.dailyInspirationEyebrow
                            : detail.category)
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFB9C9F5),
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 24,
                      height: 1.22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (detail.author case final author?) ...[
                    const SizedBox(height: 4),
                    Text(
                      author,
                      style: const TextStyle(
                        color: _gold,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    style: const TextStyle(
                      color: Color(0xFFD7E2F8),
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders one body block. Unsupported types render nothing rather than
/// breaking the article.
class _Block extends StatelessWidget {
  const _Block({required this.block});

  final InspirationBlock block;

  @override
  Widget build(BuildContext context) {
    const body = TextStyle(
      color: _ink,
      fontFamily: JcfTypography.bodyFamily,
      fontSize: 17,
      height: 1.62,
    );

    return switch (block.type) {
      BlockType.paragraph => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SelectableText(block.text, style: body),
      ),
      BlockType.heading => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 10),
        child: Semantics(
          header: true,
          child: Text(
            block.text,
            style: const TextStyle(
              color: _ink,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 22,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      BlockType.subheading => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Semantics(
          header: true,
          child: Text(
            block.text,
            style: const TextStyle(
              color: _ink,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 18,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      BlockType.pullQuote => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: InspirationPullQuote(quote: block.text, source: block.source),
      ),
      BlockType.image => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: MemberImage(
                  url: block.imageUrl,
                  asset: '$_assets/daily_inspiration_reflection.webp',
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).width * 9 / 16,
                  semanticLabel: block.altText.isEmpty ? null : block.altText,
                ),
              ),
            ),
            if (block.caption.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                block.caption,
                style: const TextStyle(
                  color: _sub,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
      BlockType.bulletList || BlockType.numberedList => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < block.items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 26,
                      child: Text(
                        block.type == BlockType.numberedList
                            ? '${i + 1}.'
                            : '•',
                        style: body.copyWith(
                          color: JcfColors.skyPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Expanded(child: Text(block.items[i], style: body)),
                  ],
                ),
              ),
          ],
        ),
      ),
      BlockType.divider => const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Divider(color: _divider, height: 1),
      ),
      // An unknown block from a newer backend is skipped, not fatal.
      BlockType.unsupported => const SizedBox.shrink(),
    };
  }
}

class InspirationPullQuote extends StatelessWidget {
  const InspirationPullQuote({
    super.key,
    required this.quote,
    this.source = '',
  });

  final String quote;
  final String source;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(18),
        border: const BorderDirectional(
          start: BorderSide(color: JcfColors.skyPrimary, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            quote,
            style: const TextStyle(
              color: _navy,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 20,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (source.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '— $source',
              style: const TextStyle(
                color: _sub,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ReflectionPromptCard extends StatelessWidget {
  const ReflectionPromptCard({
    super.key,
    required this.prompt,
    required this.reflected,
    required this.saved,
    required this.busy,
    required this.onReflect,
    required this.onSave,
    this.onShare,
  });

  final ReflectionPrompt prompt;
  final bool reflected;
  final bool saved;
  final bool busy;
  final VoidCallback onReflect;
  final VoidCallback onSave;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.self_improvement_rounded,
                size: 18,
                color: JcfColors.skyPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    t.pauseAndReflect,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: JcfColors.skyPrimary,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 13,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            prompt.question,
            style: const TextStyle(
              color: _ink,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 18,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (prompt.guidance.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              prompt.guidance,
              style: const TextStyle(
                color: _sub,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 14.5,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Semantics(
                button: true,
                toggled: reflected,
                child: FilledButton.icon(
                  onPressed: busy ? null : onReflect,
                  icon: Icon(
                    reflected
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 18,
                  ),
                  label: Text(reflected ? t.reflectedLabel : t.markAsReflected),
                  style: FilledButton.styleFrom(
                    backgroundColor: reflected
                        ? const Color(0xFF53A66F)
                        : JcfColors.skyPrimary,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: JcfTypography.bodyFamily,
                    ),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : onSave,
                icon: Icon(
                  saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 18,
                ),
                label: Text(saved ? t.savedLabel2 : t.saveForLater),
                style: OutlinedButton.styleFrom(
                  foregroundColor: JcfColors.skyPrimary,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: JcfTypography.bodyFamily,
                  ),
                ),
              ),
              if (onShare != null)
                OutlinedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: Text(t.shareLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: JcfColors.skyPrimary,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: JcfTypography.bodyFamily,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class RelatedInspirationCard extends StatelessWidget {
  const RelatedInspirationCard({
    super.key,
    required this.summary,
    required this.fallbackAsset,
    required this.onTap,
  });

  final InspirationSummary summary;
  final String fallbackAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final published = summary.publishedAt;
    final meta = [
      if (published != null) DateFormat('d MMM', locale).format(published),
      t.readingTime(summary.readingTimeMinutes),
    ].join('  ·  ');

    return Semantics(
      button: true,
      label: '${summary.category}. ${summary.title}',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: MemberImage(
                  url: summary.imageUrl,
                  asset: fallbackAsset,
                  width: double.infinity,
                  height: 96,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              summary.category.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: JcfColors.skyPrimary,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 10,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (summary.saved)
                            const Icon(
                              Icons.bookmark_rounded,
                              size: 14,
                              color: JcfColors.skyPrimary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          summary.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 14,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _sub,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: _sub,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioRow extends StatelessWidget {
  const _AudioRow({required this.audio});

  final InspirationAudio audio;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final seconds = audio.durationSeconds;
    final duration = seconds == null
        ? ''
        : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Semantics(
      button: true,
      label: t.listenToReflection,
      child: Material(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => openExternalUrl(audio.url),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: JcfColors.skyPrimary,
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t.listenToReflection,
                    style: const TextStyle(
                      color: _ink,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (duration.isNotEmpty)
                  Text(
                    duration,
                    style: const TextStyle(
                      color: _sub,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 12.5,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EndActions extends StatelessWidget {
  const _EndActions({
    required this.detail,
    required this.onOpen,
    required this.onHome,
  });

  final DailyInspirationDetail detail;
  final void Function(String slug) onOpen;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            // Previous/next appear only when the server supplied them.
            if (detail.previous case final previous?)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onOpen(previous.slug),
                  icon: const Icon(Icons.chevron_left_rounded, size: 18),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(t.previousInspiration, maxLines: 1),
                  ),
                  style: _endStyle,
                ),
              ),
            if (detail.previous != null && detail.next != null)
              const SizedBox(width: 10),
            if (detail.next case final next?)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onOpen(next.slug),
                  icon: const Icon(Icons.chevron_right_rounded, size: 18),
                  iconAlignment: IconAlignment.end,
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(t.nextInspiration, maxLines: 1),
                  ),
                  style: _endStyle,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onHome,
          child: Text(
            t.backToHome,
            style: const TextStyle(
              color: JcfColors.skyPrimary,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  static final _endStyle = OutlinedButton.styleFrom(
    foregroundColor: JcfColors.skyPrimary,
    minimumSize: const Size(0, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    textStyle: const TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w700,
      fontFamily: JcfTypography.bodyFamily,
    ),
  );
}

/// Skeleton matching the article shape — no fake quotation text.
class InspirationDetailSkeleton extends StatelessWidget {
  const InspirationDetailSkeleton({super.key});

  Widget _block({double height = 16, double? width, double radius = 8}) =>
      Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFFE3EAF6),
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        AspectRatio(aspectRatio: 16 / 9, child: _block(radius: 0)),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _block(height: 14, width: 120),
              const SizedBox(height: 18),
              for (var i = 0; i < 6; i++) ...[
                _block(height: 14),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 14),
              _block(height: 120, radius: 18),
              const SizedBox(height: 24),
              _block(height: 150, radius: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class InspirationDetailError extends StatelessWidget {
  const InspirationDetailError({
    super.key,
    required this.notFound,
    required this.onRetry,
  });

  final bool notFound;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFEAF2FF),
              child: Icon(
                notFound ? Icons.search_off_rounded : Icons.cloud_off_rounded,
                size: 36,
                color: JcfColors.skyPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            notFound ? t.inspirationUnavailable : t.genericError,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _sub,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: notFound
                ? FilledButton(
                    onPressed: () => context.go('/home'),
                    child: Text(t.exploreLatest),
                  )
                : FilledButton(onPressed: onRetry, child: Text(t.retryLabel)),
          ),
          if (notFound) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => context.go('/home'),
                child: Text(t.backToHome),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
