import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_api_client/jcf_api_client.dart';

import '../app/router.dart';
import '../features/auth/auth_controller.dart';
import 'config.dart';
import 'locale_prefs.dart';

/// The shared API client (Dio + auth interceptor + secure token store).
final apiClientProvider = Provider<JcfApiClient>((ref) {
  final client = JcfApiClient(
    baseUrl: apiBaseUrl,
    onSessionExpired: () {
      // Tokens are already cleared; drop the in-memory member and show the
      // session-expired screen (design/17) — once, not per failed call.
      ref.invalidate(authControllerProvider);
      final location =
          appRouter.routerDelegate.currentConfiguration.uri.path;
      if (location != '/session-expired') {
        appRouter.push('/session-expired');
      }
    },
  );
  // Server-generated text (errors, templates) follows the app language:
  // send the chosen locale — or the device locale — as Accept-Language.
  client.dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final code = ref.read(appLocaleProvider)?.languageCode ??
          ui.PlatformDispatcher.instance.locale.languageCode;
      options.headers['Accept-Language'] = code;
      handler.next(options);
    },
  ));
  return client;
});

final dioProvider = Provider<Dio>((ref) => ref.watch(apiClientProvider).dio);
