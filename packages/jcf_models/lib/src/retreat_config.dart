import 'accommodation_tier.dart';

/// The active retreat configuration, fetched from the API and cached in Hive
/// (1h TTL). Drives the registration flow's fees, dates, and tiers.
///
/// Mirrors `GET /api/.../retreat/active` → `retreat_configs JOIN
/// accommodation_tiers` (see product doc §6 step 11).
class RetreatConfig {
  const RetreatConfig({
    required this.id,
    required this.title,
    required this.year,
    required this.regFeeAdult,
    required this.regFeeChild,
    required this.startDate,
    required this.endDate,
    required this.venue,
    required this.paystackPublicKey,
    this.accommodationTiers = const [],
  });

  final int id;
  final String title;
  final int year;
  final num regFeeAdult;
  final num regFeeChild;
  final DateTime startDate;
  final DateTime endDate;
  final String venue;

  /// Fetched at runtime so it is rotatable without a code release
  /// (see product doc §9 secrets table).
  final String paystackPublicKey;

  final List<AccommodationTier> accommodationTiers;

  factory RetreatConfig.fromJson(Map<String, dynamic> json) {
    return RetreatConfig(
      id: json['id'] as int,
      title: json['title'] as String,
      year: json['year'] as int,
      regFeeAdult: json['reg_fee_adult'] as num,
      regFeeChild: json['reg_fee_child'] as num,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      venue: json['venue'] as String,
      paystackPublicKey: json['paystack_public_key'] as String? ?? '',
      accommodationTiers: (json['accommodation_tiers'] as List<dynamic>? ?? [])
          .map((e) => AccommodationTier.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'year': year,
        'reg_fee_adult': regFeeAdult,
        'reg_fee_child': regFeeChild,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'venue': venue,
        'paystack_public_key': paystackPublicKey,
        'accommodation_tiers':
            accommodationTiers.map((t) => t.toJson()).toList(),
      };
}
