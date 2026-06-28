/// App configuration. Override the API base at build time with:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/mobile/v1/
///
/// Defaults target a local backend: Android emulator reaches the host at
/// 10.0.2.2; use http://localhost:8000 for iOS simulator / desktop.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000/api/mobile/v1/',
);
