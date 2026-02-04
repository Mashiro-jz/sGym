import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetAllUsers {
  final AuthRepository repository;

  GetAllUsers(this.repository);

  // Funkcja call pozwala wywoływać klasę jak funkcję: getAllUsers()
  Future<List<User>> call() async {
    return await repository.getAllUsers();
  }
}
