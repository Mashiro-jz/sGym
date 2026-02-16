import 'package:agym/features/auth/domain/repositories/auth_repository.dart';

class DeleteAccount {
  final AuthRepository repository;

  DeleteAccount(this.repository);

  Future<void> call(String password) async {
    return await repository.deleteAccount(password);
  }
}
