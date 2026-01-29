// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  phoneNumber: json['phoneNumber'] as String,
  email: json['email'] as String,
  photoUrl: json['photoUrl'] as String?,
  sexRole: $enumDecode(_$SexRoleEnumMap, json['sexRole']),
  userRole: $enumDecode(_$UserRoleEnumMap, json['userRole']),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'sexRole': _$SexRoleEnumMap[instance.sexRole]!,
      'userRole': _$UserRoleEnumMap[instance.userRole]!,
    };

const _$SexRoleEnumMap = {
  SexRole.woman: 'woman',
  SexRole.man: 'man',
  SexRole.other: 'other',
};

const _$UserRoleEnumMap = {
  UserRole.client: 'client',
  UserRole.cashier: 'cashier',
  UserRole.manager: 'manager',
};
