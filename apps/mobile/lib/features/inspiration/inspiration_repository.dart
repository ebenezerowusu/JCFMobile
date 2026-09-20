import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Today's Daily Inspiration (designs 19/22), served by
/// GET /inspiration/today/ — null when nothing is scheduled yet.
class Inspiration {
  const Inspiration({
    required this.id,
    required this.date,
    required this.quote,
    required this.author,
    required this.reflection,
    this.relatedTeachingSlug,
    this.relatedTeachingTopic,
  });

  final int id;
  final DateTime date;
  final String quote;
  final String author;
  final String reflection;
  final String? relatedTeachingSlug;
  final String? relatedTeachingTopic;

  factory Inspiration.fromJson(Map<String, dynamic> json) {
    final related = json['related_teaching'] as Map<String, dynamic>?;
    return Inspiration(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      quote: json['quote'] as String? ?? '',
      author: json['author'] as String? ?? '',
      reflection: json['reflection'] as String? ?? '',
      relatedTeachingSlug: related?['slug'] as String?,
      relatedTeachingTopic: related?['topic'] as String?,
    );
  }
}

final inspirationTodayProvider = FutureProvider<Inspiration?>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get<Map<String, dynamic>>('inspiration/today/');
  if (res.statusCode == 204 || res.data == null) return null;
  return Inspiration.fromJson(res.data!);
});

// Keep DioException import used for callers catching typed errors.
typedef InspirationError = DioException;
