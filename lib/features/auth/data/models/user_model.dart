import 'package:agym/core/enums/sex_role.dart';
import 'package:agym/core/enums/user_role.dart';
import 'package:agym/features/auth/domain/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    String? photoUrl,
    required SexRole sexRole,
    required UserRole userRole,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  User toEntity() {
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email,
      photoUrl: photoUrl,
      sexRole: sexRole,
      userRole: userRole,
    );
  }
}
