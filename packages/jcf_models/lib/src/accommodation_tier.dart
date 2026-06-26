/// A bookable accommodation option for a retreat (e.g. a Windy Lodge tier).
///
/// All pricing/availability is server-driven — never hardcode tier values in
/// the client (see product doc §8 "Dynamic config, never hardcoded").
class AccommodationTier {
  const AccommodationTier({
    required this.id,
    required this.name,
    required this.pricePerPerson,
    required this.totalRooms,
    required this.roomsConfirmed,
    this.description,
  });

  final int id;
  final String name;
  final num pricePerPerson;
  final int totalRooms;
  final int roomsConfirmed;
  final String? description;

  bool get isSoldOut => roomsConfirmed >= totalRooms;
  int get roomsAvailable => (totalRooms - roomsConfirmed).clamp(0, totalRooms);

  factory AccommodationTier.fromJson(Map<String, dynamic> json) {
    return AccommodationTier(
      id: json['id'] as int,
      name: json['name'] as String,
      pricePerPerson: json['price_per_person'] as num,
      totalRooms: json['total_rooms'] as int,
      roomsConfirmed: json['rooms_confirmed'] as int? ?? 0,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price_per_person': pricePerPerson,
        'total_rooms': totalRooms,
        'rooms_confirmed': roomsConfirmed,
        'description': description,
      };
}
