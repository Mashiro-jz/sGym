import 'package:agym/core/enums/user_role.dart';
import '../repositories/auth_repository.dart';

class UpdateUserRole {
  final AuthRepository repository;

  UpdateUserRole(this.repository);

  Future<void> call({required String uid, required UserRole newRole}) async {
    return await repository.updateUserRole(uid: uid, newRole: newRole);
  }
}
