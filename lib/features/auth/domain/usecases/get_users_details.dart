import 'package:agym/features/auth/domain/entities/user.dart';
import 'package:agym/features/auth/domain/repositories/auth_repository.dart';

class GetUsersDetails {
  final AuthRepository repository;

  GetUsersDetails(this.repository);

  Future<List<User>> call(List<String> userIds) async {
    return await repository.getUsersDetails(userIds);
  }
}
