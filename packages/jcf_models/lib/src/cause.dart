/// A donation cause (mirrors the API cause serializers).
class Cause {
  const Cause({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.currency,
    required this.goalAmount,
    required this.raisedAmount,
    required this.progressPercent,
    this.imageUrl = '',
    this.impactStatement = '',
    this.type = 'specific',
  });

  final int id;
  final String slug;
  final String title;
  final String description;
  final String currency;
  final num goalAmount;
  final num raisedAmount;
  final int progressPercent;
  final String imageUrl;
  final String impactStatement;
  final String type; // 'specific' | 'ongoing'

  factory Cause.fromJson(Map<String, dynamic> json) => Cause(
        id: json['id'] as int,
        slug: json['slug'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        currency: json['currency'] as String? ?? 'GHS',
        goalAmount: json['goal_amount'] as num? ?? 0,
        raisedAmount: json['raised_amount'] as num? ?? 0,
        progressPercent: json['progress_percent'] as int? ?? 0,
        imageUrl: json['image_url'] as String? ?? '',
        impactStatement: json['impact_statement'] as String? ?? '',
        type: json['type'] as String? ?? 'specific',
      );
}
