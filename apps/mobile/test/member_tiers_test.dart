import 'package:flutter_test/flutter_test.dart';
import 'package:jcf_models/jcf_models.dart';

Member person({bool member = false, bool student = false}) => Member(
      id: 1,
      fullName: 'Ama Mensah',
      email: 'ama@example.com',
      phone: '+233200000000',
      isMember: member,
      isStudent: student,
    );

void main() {
  group('the three tiers', () {
    test('a guest record is neither', () {
      final guest = person();
      expect(guest.isSignedInMember, isFalse);
      expect(guest.canOpenPrivate, isFalse);
    });

    test('a member has an account but not private material', () {
      // The whole point of the middle tier: membership is not a key to
      // private teachings.
      final m = person(member: true);
      expect(m.isSignedInMember, isTrue);
      expect(m.canOpenPrivate, isFalse);
    });

    test('a student has both', () {
      final s = person(member: true, student: true);
      expect(s.isSignedInMember, isTrue);
      expect(s.canOpenPrivate, isTrue);
    });

    test('the student flag alone opens private material', () {
      // Nothing in the database enforces that a student is also a
      // member, so the app must not assume the pair either.
      final s = person(student: true);
      expect(s.canOpenPrivate, isTrue);
      expect(s.isSignedInMember, isTrue);
    });

    test('both flags survive a round trip through json', () {
      final s = person(member: true, student: true);
      final back = Member.fromJson(s.toJson());
      expect(back.isMember, isTrue);
      expect(back.isStudent, isTrue);
    });

    test('a payload missing the flags defaults to no entitlement', () {
      final back = Member.fromJson({
        'id': 2,
        'full_name': 'Kofi',
        'email': '',
        'phone': '',
      });
      expect(back.isSignedInMember, isFalse);
      expect(back.canOpenPrivate, isFalse);
    });
  });
}
