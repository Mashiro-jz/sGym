import 'package:sgym/features/auth/domain/repositories/auth_repository.dart';

class LogoutUser {
  AuthRepository authRepository;

  LogoutUser(this.authRepository);

  Future<void> call() async {
    return authRepository.logout();
  }
}
