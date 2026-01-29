import 'package:agym/features/auth/domain/entities/user.dart';
import 'package:agym/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository authRepository;

  RegisterUser(this.authRepository);

  Future<User> call({
    required String email,
    required String password,
    required User user,
  }) async {
    return authRepository.register(
      email: email,
      password: password,
      user: user,
    );
  }
}
