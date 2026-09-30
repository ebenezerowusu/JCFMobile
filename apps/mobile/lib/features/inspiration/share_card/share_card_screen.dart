import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../inspiration_detail_repository.dart' show InspirationNotFound;
import 'share_card_canvas.dart';
import 'share_card_models.dart';
import 'share_card_renderer.dart';

const _sub = Color(0xFF667085);
const _ink = Color(0xFF172033);
const _divider = Color(0xFFE4E7EC);
const _bg = Color(0xFFF8F8F5);

/// Composer for the Daily Inspiration share card. Available to everyone —
/// sharing a public inspiration needs no account.
class ShareCardScreen extends ConsumerStatefulWidget {
  const ShareCardScreen({super.key, required this.identifier});

  final String identifier;

  @override
  ConsumerState<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends ConsumerState<ShareCardScreen> {
  ShareCardConfiguration? _config;

  /// Only one render may run at a time, so a double tap cannot start two.
  bool _saving = false;
  bool _sharing = false;

  bool get _busy => _saving || _sharing;

  ShareCardConfiguration _configFor(ShareCardData data) =>
      _config ??= ShareCardConfiguration.defaults(data);

  void _update(ShareCardData data,
      ShareCardConfiguration Function(ShareCardConfiguration) change) {
    setState(() => _config = change(_configFor(data)));
  }

  /// Switching format keeps the settings that still apply, but moves off a
  /// template that has no artwork for the new format rather than stretching.
  void _setFormat(ShareCardData data, ShareCardFormat format) {
    final current = _configFor(data);
    var templateId = current.templateId;
    if (!data.templateById(templateId).supports(format)) {
      final fallback = data.templates.firstWhere(
        (t) => t.supports(format),
        orElse: () => data.templateById(data.defaultTemplateId),
      );
      templateId = fallback.id;
    }
    _update(data, (c) => c.copyWith(format: format, templateId: templateId));
  }

  void _setTemplate(ShareCardData data, ShareCardTemplate template) {
    // Follow the template's recommended colour unless the user already
    // chose the other one deliberately.
    final current = _configFor(data);
    final previous = data.templateById(current.templateId);
    final followed = current.textColor == previous.recommendedTextColor;
    _update(
        data,
        (c) => c.copyWith(
              templateId: template.id,
              textColor:
                  followed ? template.recommendedTextColor : c.textColor,
            ));
  }

  Future<void> _save(ShareCardData data) async {
    if (_busy) return;
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final bytes = await renderShareCard(
          context: context, data: data, config: _configFor(data));
      // Permission is requested here, when the user asks to save — never on
      // opening the composer.
      if (!await Gal.hasAccess(toAlbum: true)) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          messenger.showSnackBar(
              SnackBar(content: Text(t.permissionDenied)));
          return;
        }
      }
      await Gal.putImageBytes(bytes,
          name: shareCardFileName(data, _configFor(data).format));
      messenger.showSnackBar(SnackBar(content: Text(t.imageSaved)));
    } on GalException catch (error) {
      messenger.showSnackBar(SnackBar(
        content: Text(error.type == GalExceptionType.accessDenied
            ? t.permissionDenied
            : t.unableToSave),
      ));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.unableToGenerate)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share(ShareCardData data) async {
    if (_busy) return;
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sharing = true);
    try {
      final bytes = await renderShareCard(
          context: context, data: data, config: _configFor(data));
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile.fromData(bytes,
              name: shareCardFileName(data, _configFor(data).format),
              mimeType: 'image/png'),
        ],
        text: data.canonicalUrl,
      ));
    } catch (_) {
      // If the image cannot be produced, the link is still shareable.
      messenger.showSnackBar(SnackBar(
        content: Text(t.unableToGenerate),
        action: SnackBarAction(
          label: t.shareLink,
          onPressed: () => SharePlus.instance
              .share(ShareParams(text: data.canonicalUrl)),
        ),
      ));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final async = ref.watch(shareCardDataProvider(widget.identifier));
    final data = async.asData?.value;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _ink,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.createShareCard,
          style: const TextStyle(
            color: _ink,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (data != null)
            TextButton(
              onPressed: _configFor(data).matchesDefaults(data)
                  ? null
                  : () => setState(
                      () => _config = ShareCardConfiguration.defaults(data)),
              child: Text(t.resetLabel),
            ),
        ],
      ),
      body: data == null
          ? (async.hasError
              ? _ErrorView(
                  notFound: async.error is InspirationNotFound,
                  onRetry: () => ref
                      .invalidate(shareCardDataProvider(widget.identifier)),
                )
              : const Center(child: CircularProgressIndicator()))
          : data.sharingAllowed
              ? _buildComposer(context, t, data)
              : _ProhibitedView(message: t.sharingNotAllowed),
      bottomNavigationBar: data == null || !data.sharingAllowed
          ? null
          : _ActionBar(
              saving: _saving,
              sharing: _sharing,
              onSave: () => _save(data),
              onShare: () => _share(data),
            ),
    );
  }

  Widget _buildComposer(
      BuildContext context, AppLocalizations t, ShareCardData data) {
    final config = _configFor(data);
    final template = data.templateById(config.templateId);
    final available =
        data.templates.where((x) => x.supports(config.format)).toList();
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 600 ? (width - 560) / 2 : 20.0;
    // Fit the preview to the available width, capped so a story card does
    // not dominate the screen.
    final previewWidth = (width - horizontal * 2).clamp(200.0, 360.0);
    final previewScale = config.format == ShareCardFormat.square
        ? previewWidth / config.format.exportSize.width
        : (previewWidth * 0.72) / config.format.exportSize.width;

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
      children: [
        Center(
          child: Semantics(
            label: t.shareCardPreviewLabel(
              _templateName(t, template.id),
              config.format == ShareCardFormat.square
                  ? t.formatSquare
                  : t.formatStory,
              switch (config.alignment) {
                ShareCardTextAlignment.start => t.alignStart,
                ShareCardTextAlignment.center => t.alignCenter,
                ShareCardTextAlignment.end => t.alignEnd,
              },
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: ShareCardCanvas(
                data: data,
                config: config,
                scale: previewScale,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),

        // --- format ---
        _Segmented<ShareCardFormat>(
          value: config.format,
          options: [
            (ShareCardFormat.square, t.formatSquare, Icons.crop_square_rounded),
            (ShareCardFormat.story, t.formatStory, Icons.crop_portrait_rounded),
          ],
          onChanged: (format) => _setFormat(data, format),
        ),
        const SizedBox(height: 22),

        // --- templates ---
        _SectionLabel(t.chooseAStyle),
        const SizedBox(height: 10),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: available.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final item = available[i];
              final selected = item.id == config.templateId;
              return Semantics(
                // "Light" is both a style and a text colour; the key and the
                // section heading keep them distinguishable.
                key: ValueKey('template-${item.id}'),
                button: true,
                selected: selected,
                label: _templateName(t, item.id),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _setTemplate(data, item),
                  child: SizedBox(
                    width: 84,
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? JcfColors.skyPrimary
                                  : _divider,
                              width: selected ? 2.5 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  item.assetFor(ShareCardFormat.square) ??
                                      item.assetFor(config.format)!,
                                  fit: BoxFit.cover,
                                  excludeFromSemantics: true,
                                  errorBuilder: (_, _, _) => const ColoredBox(
                                      color: Color(0xFFEAF2FF)),
                                ),
                                if (selected)
                                  const Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: EdgeInsets.all(4),
                                      child: CircleAvatar(
                                        radius: 9,
                                        backgroundColor:
                                            JcfColors.skyPrimary,
                                        child: Icon(Icons.check_rounded,
                                            size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _templateName(t, item.id),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected ? JcfColors.skyPrimary : _sub,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 11.5,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // --- alignment ---
        _SectionLabel(t.textAlignment),
        const SizedBox(height: 10),
        _Segmented<ShareCardTextAlignment>(
          value: config.alignment,
          options: [
            (ShareCardTextAlignment.start, t.alignStart,
                Icons.format_align_left_rounded),
            (ShareCardTextAlignment.center, t.alignCenter,
                Icons.format_align_center_rounded),
            (ShareCardTextAlignment.end, t.alignEnd,
                Icons.format_align_right_rounded),
          ],
          onChanged: (value) =>
              _update(data, (c) => c.copyWith(alignment: value)),
        ),
        const SizedBox(height: 20),

        // --- text colour ---
        _SectionLabel(t.textColor),
        const SizedBox(height: 10),
        _Segmented<ShareCardTextColorMode>(
          value: config.textColor,
          options: [
            (ShareCardTextColorMode.light, t.textLight,
                Icons.light_mode_rounded),
            (ShareCardTextColorMode.dark, t.textDark, Icons.dark_mode_rounded),
          ],
          onChanged: (value) =>
              _update(data, (c) => c.copyWith(textColor: value)),
        ),
        const SizedBox(height: 20),

        // --- text size ---
        _SectionLabel(t.textSize),
        const SizedBox(height: 10),
        _Segmented<ShareCardTextSize>(
          value: config.textSize,
          options: [
            (ShareCardTextSize.small, t.sizeSmall, null),
            (ShareCardTextSize.medium, t.sizeMedium, null),
            (ShareCardTextSize.large, t.sizeLarge, null),
          ],
          onChanged: (value) =>
              _update(data, (c) => c.copyWith(textSize: value)),
        ),
        const SizedBox(height: 14),

        // --- content switches ---
        _Toggle(
          label: t.showLogo,
          value: config.showLogo,
          onChanged: (v) => _update(data, (c) => c.copyWith(showLogo: v)),
        ),
        _Toggle(
          label: t.showSource,
          value: config.showSource,
          // Nothing to show when the inspiration carries no attribution.
          onChanged: data.hasSource
              ? (v) => _update(data, (c) => c.copyWith(showSource: v))
              : null,
        ),
        _Toggle(
          label: t.showWebsite,
          value: config.showWebsite,
          onChanged: data.websiteLabel.isEmpty
              ? null
              : (v) => _update(data, (c) => c.copyWith(showWebsite: v)),
        ),
      ],
    );
  }

  String _templateName(AppLocalizations t, String id) => switch (id) {
        'dawn' => t.templateDawn,
        'stillness' => t.templateStillness,
        'light' => t.templateLight,
        _ => t.templateCosmic,
      };
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: const TextStyle(
          color: _ink,
          fontFamily: JcfTypography.bodyFamily,
          fontSize: 14.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final List<(T, String, IconData?)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider),
      ),
      child: Row(
        children: [
          for (final (item, label, icon) in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: item == value,
                label: label,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onChanged(item),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      color: item == value ? JcfColors.skyPrimary : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon,
                              size: 16,
                              color: item == value ? Colors.white : _sub),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  item == value ? Colors.white : _ink,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 13,
                              fontWeight: item == value
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle(
      {required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: value && enabled,
      onChanged: onChanged,
      title: Text(
        label,
        style: TextStyle(
          color: enabled ? _ink : _sub,
          fontFamily: JcfTypography.bodyFamily,
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.saving,
    required this.sharing,
    required this.onSave,
    required this.onShare,
  });

  final bool saving;
  final bool sharing;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final busy = saving || sharing;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: _bg,
          border: Border(top: BorderSide(color: _divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                // Disabled while either action runs, so no double render.
                onPressed: busy ? null : onSave,
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_rounded, size: 18),
                label: Text(t.saveImage,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                style: OutlinedButton.styleFrom(
                  foregroundColor: JcfColors.skyPrimary,
                  side: const BorderSide(color: JcfColors.skyPrimary),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: JcfTypography.bodyFamily,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: busy ? null : onShare,
                icon: sharing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.share_rounded, size: 18),
                label: Text(t.shareLabel,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                style: FilledButton.styleFrom(
                  backgroundColor: JcfColors.skyPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: JcfTypography.bodyFamily,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProhibitedView extends StatelessWidget {
  const _ProhibitedView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFEAF2FF),
            child: Icon(Icons.lock_rounded,
                size: 32, color: JcfColors.skyPrimary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _sub,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton(
            onPressed: () => context.go('/home'),
            child: Text(t.backToHome),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.notFound, required this.onRetry});

  final bool notFound;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFEAF2FF),
            child: Icon(Icons.cloud_off_rounded,
                size: 32, color: JcfColors.skyPrimary),
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
        const SizedBox(height: 16),
        Center(
          child: notFound
              ? FilledButton(
                  onPressed: () => context.go('/home'),
                  child: Text(t.backToHome),
                )
              : FilledButton(onPressed: onRetry, child: Text(t.retryLabel)),
        ),
      ],
    );
  }
}
