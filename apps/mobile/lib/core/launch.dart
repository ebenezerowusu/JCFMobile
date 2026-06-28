import 'package:url_launcher/url_launcher.dart';

/// Open an external URL (media links, Paystack hosted checkout).
Future<bool> openExternalUrl(String url) async {
  if (url.isEmpty) return false;
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
