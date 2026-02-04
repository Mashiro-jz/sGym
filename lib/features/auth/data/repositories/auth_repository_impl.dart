import 'package:agym/core/enums/user_role.dart';
import 'package:agym/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:agym/features/auth/data/models/user_model.dart';
import 'package:agym/features/auth/domain/entities/user.dart';
import 'package:agym/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl({required this.authRemoteDataSource});

  @override
  Future<User?> getCurrentUser() async {
    final userModel = await authRemoteDataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Future<User> login({required String email, required String password}) async {
    final userModel = await authRemoteDataSource.login(
      email: email,
      password: password,
    );
    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    return await authRemoteDataSource.logout();
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required User user,
  }) async {
    final userModel = UserModel(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      phoneNumber: user.phoneNumber,
      email: email,
      photoUrl: user.photoUrl,
      sexRole: user.sexRole,
      userRole: user.userRole,
    );

    final registeredModel = await authRemoteDataSource.register(
      email: email,
      password: password,
      user: userModel,
    );

    return registeredModel.toEntity();
  }

  @override
  Future<List<User>> getAllUsers() async {
    final userModels = await authRemoteDataSource.getAllUsers();
    return userModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> updateUserRole({
    required String uid,
    required UserRole newRole,
  }) async {
    await authRemoteDataSource.updateUserRole(uid: uid, newRole: newRole);
  }
}
