import 'member.dart';

/// The result of a successful OTP verification: tokens + the member profile.
class AuthSession {
  const AuthSession({
    required this.access,
    required this.refresh,
    required this.member,
  });

  final String access;
  final String refresh;
  final Member member;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        access: json['access'] as String,
        refresh: json['refresh'] as String,
        member: Member.fromJson(json['member'] as Map<String, dynamic>),
      );
}
