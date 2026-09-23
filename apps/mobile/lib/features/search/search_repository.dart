import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';

/// One row of the global search results (design 31).
class SearchResult {
  const SearchResult({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.audience,
    this.slug,
    this.id,
    this.thumbnailUrl = '',
    this.durationSeconds,
    this.minutes,
    this.date,
    this.locked = false,
    this.views,
  });

  /// video | audio | practice | programme | event | centre | announcement
  final String kind;
  final String title;
  final String subtitle;
  final String description;
  final String audience;
  final String? slug;
  final int? id;
  final String thumbnailUrl;
  final int? durationSeconds;
  final int? minutes;
  final String? date;
  final bool locked;
  final int? views;

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
        kind: json['kind'] as String,
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        description: json['description'] as String? ?? '',
        audience: json['audience'] as String? ?? 'public',
        slug: json['slug'] as String?,
        id: json['id'] as int?,
        thumbnailUrl: json['thumbnail_url'] as String? ?? '',
        durationSeconds: json['duration_seconds'] as int?,
        minutes: json['minutes'] as int?,
        date: json['date'] as String?,
        locked: json['locked'] as bool? ?? false,
        views: json['views'] as int?,
      );
}

class SearchRepository {
  SearchRepository(this._dio);

  final Dio _dio;

  Future<List<SearchResult>> search(String query) async {
    final res = await _dio.get<Map<String, dynamic>>(
        'search/', queryParameters: {'q': query});
    return [
      for (final row in (res.data?['results'] as List? ?? []))
        SearchResult.fromJson(row as Map<String, dynamic>)
    ];
  }

  Future<List<String>> popular() async {
    final res = await _dio.get<Map<String, dynamic>>('search/popular/');
    return [for (final t in (res.data?['results'] as List? ?? [])) t as String];
  }
}

final searchRepositoryProvider = Provider<SearchRepository>(
    (ref) => SearchRepository(ref.watch(dioProvider)));

final popularSearchesProvider =
    FutureProvider.autoDispose<List<String>>((ref) {
  return ref.watch(searchRepositoryProvider).popular();
});

/// Recent searches live on the device only (design 30).
class RecentSearchStore {
  static const _key = 'recent_searches';
  static const _max = 8;

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  Future<List<String>> add(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key) ?? [];
    items.removeWhere((t) => t.toLowerCase() == term.toLowerCase());
    items.insert(0, term);
    final capped = items.take(_max).toList();
    await prefs.setStringList(_key, capped);
    return capped;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final recentSearchStoreProvider =
    Provider<RecentSearchStore>((ref) => RecentSearchStore());
