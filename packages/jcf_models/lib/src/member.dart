/// A logged-in member/student (mirrors the API's MemberSerializer).
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

  /// True if the member may access premium content / members-only programs.
  bool get hasPremiumAccess => isMember || isStudent;

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
