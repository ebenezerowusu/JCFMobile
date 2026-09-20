import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_ui/jcf_ui.dart';

import 'app/router.dart';
import 'core/locale_prefs.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: JcfApp()));
}

class JcfApp extends ConsumerWidget {
  const JcfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp.router(
      title: 'JCF App',
      debugShowCheckedModeBanner: false,
      theme: JcfTheme.light(),
      locale: locale, // null -> follow the device locale
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
