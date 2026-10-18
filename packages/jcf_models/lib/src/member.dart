/// The signed-in person (mirrors the API's MemberSerializer).
///
/// Three tiers: a guest who is not signed in, a member, and a student.
/// A member gets an account and general content; a student also gets
/// private teachings, learning materials and events.
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

  /// Whether this person has an account: the gate for registering,
  /// donating, booking, groups and saved progress.
  ///
  /// Set by the website on join-centre approval, and by enrolling
  /// someone on a programme. Whether they may *log in* is a separate
  /// question the server owns; this never grants anything.
  bool get isSignedInMember => isMember || isStudent;

  /// Whether this person may open private, students-only material.
  ///
  /// Membership is not a key to it — studying is. Checked on its own
  /// rather than assuming a student also carries [isMember], because
  /// nothing in the database enforces the pair.
  bool get canOpenPrivate => isStudent;

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
