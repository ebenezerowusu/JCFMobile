/// A program tier (accommodation option) as returned by the programs API.
class ProgramTier {
  const ProgramTier({
    required this.id,
    required this.name,
    required this.pricePerPerson,
    required this.roomsAvailable,
    required this.isSoldOut,
    this.description = '',
  });

  final int id;
  final String name;
  final num pricePerPerson;
  final int roomsAvailable;
  final bool isSoldOut;
  final String description;

  factory ProgramTier.fromJson(Map<String, dynamic> json) => ProgramTier(
        id: json['id'] as int,
        name: json['name'] as String,
        pricePerPerson: json['price_per_person'] as num? ?? 0,
        roomsAvailable: json['rooms_available'] as int? ?? 0,
        isSoldOut: json['is_sold_out'] as bool? ?? false,
        description: json['description'] as String? ?? '',
      );
}

/// A program cost line item.
class CostLineItem {
  const CostLineItem({
    required this.id,
    required this.label,
    required this.amount,
    required this.unit,
  });

  final int id;
  final String label;
  final num amount;
  final String unit; // 'flat' | 'per_person'

  factory CostLineItem.fromJson(Map<String, dynamic> json) => CostLineItem(
        id: json['id'] as int,
        label: json['label'] as String,
        amount: json['amount'] as num? ?? 0,
        unit: json['unit'] as String? ?? 'flat',
      );
}

/// A field definition in a program's dynamic registration form.
class FormField {
  const FormField({
    required this.name,
    required this.label,
    required this.type,
    required this.required,
  });

  final String name;
  final String label;
  final String type; // text | number | email | phone | textarea | ...
  final bool required;

  factory FormField.fromJson(Map<String, dynamic> json) => FormField(
        name: json['name'] as String? ?? '',
        label: json['label'] as String? ?? '',
        type: json['type'] as String? ?? 'text',
        required: json['required'] as bool? ?? false,
      );
}

/// A program (event/retreat) — list + detail.
class Program {
  const Program({
    required this.id,
    required this.slug,
    required this.title,
    required this.year,
    required this.audience,
    required this.requiresPayment,
    required this.currency,
    this.description = '',
    this.venue = '',
    this.location = '',
    this.startsOn,
    this.endsOn,
    this.imageUrl = '',
    this.registrationOpen = true,
    this.tiers = const [],
    this.costLineItems = const [],
    this.formSchema = const [],
  });

  final int id;
  final String slug;
  final String title;
  final int year;
  final String audience; // public | members | students
  final bool requiresPayment;
  final String currency;
  final String description;
  final String venue;
  final String location;
  final String? startsOn;
  final String? endsOn;
  final String imageUrl;
  final bool registrationOpen;
  final List<ProgramTier> tiers;
  final List<CostLineItem> costLineItems;
  final List<FormField> formSchema;

  factory Program.fromJson(Map<String, dynamic> json) => Program(
        id: json['id'] as int,
        slug: json['slug'] as String,
        title: json['title'] as String,
        year: json['year'] as int? ?? 0,
        audience: json['audience'] as String? ?? 'public',
        requiresPayment: json['requires_payment'] as bool? ?? false,
        currency: json['currency'] as String? ?? 'GHS',
        description: json['description'] as String? ?? '',
        venue: json['venue'] as String? ?? '',
        location: json['location'] as String? ?? '',
        startsOn: json['starts_on'] as String?,
        endsOn: json['ends_on'] as String?,
        imageUrl: json['image_url'] as String? ?? '',
        registrationOpen: json['registration_open'] as bool? ?? true,
        tiers: (json['accommodation_tiers'] as List<dynamic>? ?? [])
            .map((e) => ProgramTier.fromJson(e as Map<String, dynamic>))
            .toList(),
        costLineItems: (json['cost_line_items'] as List<dynamic>? ?? [])
            .map((e) => CostLineItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        formSchema: (json['form_schema'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(FormField.fromJson)
            .toList(),
      );
}

/// A member's registration for a program.
class Registration {
  const Registration({
    required this.id,
    required this.reference,
    required this.programTitle,
    required this.quantity,
    required this.amount,
    required this.currency,
    required this.status,
    this.qrUrl = '',
  });

  final int id;
  final String reference;
  final String programTitle;
  final int quantity;
  final num amount;
  final String currency;
  final String status; // pending | confirmed | cancelled
  final String qrUrl;

  bool get isConfirmed => status == 'confirmed';

  factory Registration.fromJson(Map<String, dynamic> json) => Registration(
        id: json['id'] as int,
        reference: json['reference'] as String? ?? '',
        programTitle: json['program_title'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 1,
        amount: json['amount'] as num? ?? 0,
        currency: json['currency'] as String? ?? 'GHS',
        status: json['status'] as String? ?? 'pending',
        qrUrl: json['qr_url'] as String? ?? '',
      );
}
