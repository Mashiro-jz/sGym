import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/sex_role.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String? photoUrl;
  final SexRole sexRole;
  final UserRole userRole;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    this.photoUrl,
    required this.sexRole,
    required this.userRole,
  });
}
