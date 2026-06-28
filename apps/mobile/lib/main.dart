import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_ui/jcf_ui.dart';

import 'app/router.dart';

void main() {
  runApp(const ProviderScope(child: JcfApp()));
}

class JcfApp extends StatelessWidget {
  const JcfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JCF App',
      debugShowCheckedModeBanner: false,
      theme: JcfTheme.light(),
      routerConfig: createRouter(),
    );
  }
}
