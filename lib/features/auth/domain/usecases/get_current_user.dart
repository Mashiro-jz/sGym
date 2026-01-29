import 'package:agym/features/auth/domain/entities/user.dart';
import 'package:agym/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser {
  AuthRepository authRepository;

  GetCurrentUser(this.authRepository);

  Future<User?> call() async {
    return authRepository.getCurrentUser();
  }
}
