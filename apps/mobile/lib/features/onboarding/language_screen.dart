import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../core/brand.dart';
import '../../core/locale_prefs.dart';
import 'onboarding_prefs.dart';

class _Lang {
  const _Lang(this.code, this.name, {this.available = true});
  final String code;
  final String name;
  final bool available;
}

/// Wave-1 UI languages are selectable; the rest are visible but pending
/// translation, so the worldwide ambition is on screen from day one.
const _languages = <_Lang>[
  _Lang('en', 'English'),
  _Lang('fr', 'Français'),
  _Lang('es', 'Español'),
  _Lang('de', 'Deutsch'),
  _Lang('pt', 'Português'),
];

const _comingSoon = <_Lang>[
  _Lang('it', 'Italiano', available: false),
  _Lang('ru', 'Русский', available: false),
  _Lang('nl', 'Nederlands', available: false),
  _Lang('ar', 'العربية', available: false),
  _Lang('hi', 'हिन्दी', available: false),
  _Lang('zh', '中文（简体）', available: false),
  _Lang('tw', 'Twi', available: false),
  _Lang('ee', 'Eʋegbe (Ewe)', available: false),
  _Lang('gaa', 'Ga', available: false),
  _Lang('dag', 'Dagbani', available: false),
  _Lang('ha', 'Hausa', available: false),
];

/// Language chooser (design/6): search, radio list, Continue, More languages.
class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String _selected = 'en';
  String _query = '';
  bool _showMore = false;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(appLocaleProvider)?.languageCode ?? 'en';
  }

  Future<void> _continue() async {
    await ref.read(appLocaleProvider.notifier).set(Locale(_selected));
    await ref.read(onboardingPrefsProvider).markSeen();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final visible = [
      ..._languages,
      if (_showMore) ..._comingSoon,
    ].where((l) => q.isEmpty || l.name.toLowerCase().contains(q)).toList();

    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            const JcfLogo(size: 96),
            const SizedBox(height: 14),
            const Text(
              'Choose your language',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: JcfColors.inkOnLight,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You can change this anytime in Settings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF54689B),
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search languages',
                  hintStyle: const TextStyle(color: Color(0xFF7C8DB5)),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF7C8DB5)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final lang = visible[i];
                  final selected = lang.code == _selected;
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: lang.available
                        ? () => setState(() => _selected = lang.code)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFE3EEFF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? JcfColors.skyPrimary
                              : Colors.transparent,
                          width: 1.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              lang.name,
                              style: TextStyle(
                                color: lang.available
                                    ? JcfColors.inkOnLight
                                    : const Color(0xFF9AA7C7),
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!lang.available)
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text(
                                'Coming soon',
                                style: TextStyle(
                                  color: Color(0xFF9AA7C7),
                                  fontFamily: JcfTypography.bodyFamily,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          selected
                              ? const CircleAvatar(
                                  radius: 13,
                                  backgroundColor: JcfColors.skyPrimary,
                                  child: Icon(Icons.check,
                                      size: 17, color: Colors.white),
                                )
                              : Container(
                                  height: 26,
                                  width: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFFB9C6E2),
                                        width: 2),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      backgroundColor: JcfColors.skyPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: JcfTypography.bodyFamily,
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _showMore = !_showMore),
                    child: Text(
                      _showMore ? 'Fewer languages' : 'More languages',
                      style: const TextStyle(
                        color: JcfColors.skyPrimary,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
