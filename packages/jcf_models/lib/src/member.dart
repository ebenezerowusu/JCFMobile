/// The signed-in person (mirrors the API's MemberSerializer).
///
/// The app has two tiers: guests, who are not signed in, and students,
/// who are. Ask [isApproved]; `isMember` is the flag behind it.
class Member {
  const Member({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.isMember,
    this.centre,
  });

  final int id;
  final String fullName;
  final String email;
  final String phone;
  final bool isMember;
  final String? centre;

  /// Whether JCF has approved this person.
  ///
  /// [isMember] is the flag, and the only one the app reads. The website
  /// sets it when a join-centre request is approved, and enrolling
  /// someone on a programme sets it too. There was an `is_student` flag
  /// as well; nothing ever set it automatically, the server no longer
  /// sends it, and the app must not acquire a second answer to a question
  /// with one.
  ///
  /// The only tier question the app asks, and the server decides access
  /// regardless — this chooses what to draw, it never grants anything.
  bool get isApproved => isMember;

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] as int,
        fullName: json['full_name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        isMember: json['is_member'] as bool? ?? false,
        centre: json['centre'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'is_member': isMember,
        'centre': centre,
      };
}
