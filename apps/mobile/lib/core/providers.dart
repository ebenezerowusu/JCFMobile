import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_api_client/jcf_api_client.dart';

import 'config.dart';

/// The shared API client (Dio + auth interceptor + secure token store).
final apiClientProvider = Provider<JcfApiClient>((ref) {
  return JcfApiClient(baseUrl: apiBaseUrl);
});

final dioProvider = Provider<Dio>((ref) => ref.watch(apiClientProvider).dio);
