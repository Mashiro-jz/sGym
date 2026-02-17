// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GymClassModel _$GymClassModelFromJson(Map<String, dynamic> json) =>
    _GymClassModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      trainerId: json['trainerId'] as String,
      startTime: const TimestampConverter().fromJson(json['startTime']),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      capacity: (json['capacity'] as num).toInt(),
      registeredUserIds:
          (json['registeredUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$GymClassModelToJson(_GymClassModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'trainerId': instance.trainerId,
      'startTime': const TimestampConverter().toJson(instance.startTime),
      'durationMinutes': instance.durationMinutes,
      'capacity': instance.capacity,
      'registeredUserIds': instance.registeredUserIds,
    };
