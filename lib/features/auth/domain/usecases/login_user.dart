import 'package:agym/features/auth/domain/entities/user.dart';
import 'package:agym/features/auth/domain/repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository authRepository;

  LoginUser(this.authRepository);

  Future<User> call({required String email, required String password}) async {
    return authRepository.login(email: email, password: password);
  }
}
