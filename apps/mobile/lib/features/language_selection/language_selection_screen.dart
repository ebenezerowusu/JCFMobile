import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../welcome/welcome_widgets.dart'
    show deepNavy, warmWhite, supportingText;
import 'language_selection_controller.dart';
import 'language_selection_widgets.dart';

/// Language Selection (owner spec).
///
/// Two entry points, one screen. On a first launch there is nowhere to go
/// back to, so Back is hidden; from Settings it is shown and leaving
/// without confirming discards the choice.
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({
    super.key,
    this.mode = LanguageSelectionMode.firstLaunch,
  });

  final LanguageSelectionMode mode;

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  final _search = TextEditingController();

  bool get _isFirstLaunch =>
      widget.mode == LanguageSelectionMode.firstLaunch;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final state = ref.watch(languageSelectionControllerProvider);

    return PopScope(
      // Nothing behind a first launch but the splash, which must not be
      // returned to. From Settings, leaving simply discards the choice —
      // nothing was persisted.
      canPop: !_isFirstLaunch,
      child: Scaffold(
        backgroundColor: warmWhite,
        body: Column(
          children: [
            LanguageSelectionHeader(
              showBack: !_isFirstLaunch,
              onBack: () =>
                  context.canPop() ? context.pop() : context.go('/welcome'),
            ),
            // Slivers rather than nested Columns: at large text sizes an
            // intro plus a search field can exceed the space a fixed
            // Column leaves for the list, and the whole thing overflows.
            // Scrolling them together cannot.
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _intro(t)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: LanguageSearchField(
                        controller: _search,
                        onChanged: (value) => ref
                            .read(languageSelectionControllerProvider
                                .notifier)
                            .updateSearchQuery(value, t),
                        onClear: _clearSearch,
                      ),
                    ),
                  ),
                  _list(t, state),
                ],
              ),
            ),
            LanguageContinueBar(
              label: t.languageContinue,
              enabled: state.canContinue,
              loading: state.isSaving,
              errorMessage: state.errorMessage == null
                  ? null
                  : t.languageSaveFailed,
              onRetry: _confirm,
              onPressed: _confirm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _intro(AppLocalizations t) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                t.languageSelectionTitle,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: deepNavy,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.languageSelectionDescription,
              style: const TextStyle(
                  fontSize: 13.5, height: 1.45, color: supportingText),
            ),
          ],
        ),
      );

  void _clearSearch() {
    _search.clear();
    ref
        .read(languageSelectionControllerProvider.notifier)
        .clearSearch(AppLocalizations.of(context)!);
  }

  Widget _list(AppLocalizations t, LanguageSelectionState state) {
    if (!state.hasResults) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: LanguageEmptyState(onClear: _clearSearch),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      sliver: SliverList.separated(
        itemCount: state.filtered.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final language = state.filtered[index];
          return LanguageListTile(
            key: ValueKey('language-${language.tag}'),
            language: language,
            selected: language == state.selected,
            onTap: () => ref
                .read(languageSelectionControllerProvider.notifier)
                .selectLanguage(language),
          );
        },
      ),
    );
  }

  Future<void> _confirm() async {
    final controller =
        ref.read(languageSelectionControllerProvider.notifier);
    // From Settings, an unchanged choice needs no write at all.
    final ok = await controller.confirmSelection(
        skipUnchanged: !_isFirstLaunch);
    if (!mounted || !ok) return;

    if (_isFirstLaunch) {
      // Replace: the splash is behind this and must not be reachable.
      context.go('/onboarding');
    } else {
      context.canPop() ? context.pop() : context.go('/more');
    }
  }
}
