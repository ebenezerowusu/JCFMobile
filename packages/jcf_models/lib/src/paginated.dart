/// A DRF PageNumberPagination response.
class Paginated<T> {
  const Paginated({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final List<T> results;
  final String? next;
  final String? previous;

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    return Paginated(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => itemFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
