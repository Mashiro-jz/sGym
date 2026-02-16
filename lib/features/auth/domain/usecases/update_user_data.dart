import 'package:agym/core/enums/sex_role.dart';
import 'package:agym/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserData {
  final AuthRepository repository;

  UpdateUserData(this.repository);

  Future<void> call({
    required String uid,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    String? photoUrl,
    required SexRole sexRole,
  }) async {
    return await repository.updateUserProfile(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email,
      photoUrl: photoUrl,
      sexRole: sexRole,
    );
  }
}
