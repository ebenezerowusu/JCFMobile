/// The signed-in person (mirrors the API's MemberSerializer).
///
/// The app has two tiers: guests, who are not signed in, and students,
/// who are. Both flags below are still carried because the API sends
/// them — `is_member` remains a JCFAdmin CRM marker — but the app does
/// not branch on which one is set. Ask [isApproved].
class Member {
  const Member({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.isMember,
    required this.isStudent,
    this.centre,
  });

  final int id;
  final String fullName;
  final String email;
  final String phone;
  final bool isMember;
  final bool isStudent;
  final String? centre;

  /// Whether JCF has approved this person, by either flag.
  ///
  /// The only tier question the app asks. The server decides access
  /// regardless; this is for choosing what to draw, never for granting
  /// anything.
  bool get isApproved => isMember || isStudent;

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] as int,
        fullName: json['full_name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        isMember: json['is_member'] as bool? ?? false,
        isStudent: json['is_student'] as bool? ?? false,
        centre: json['centre'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'is_member': isMember,
        'is_student': isStudent,
        'centre': centre,
      };
}
