import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'gym_class_model.freezed.dart';
part 'gym_class_model.g.dart';

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    // Jeśli z bazy przyjdzie Timestamp, zamień na DateTime
    if (json is Timestamp) return json.toDate();
    // Jeśli przyjdzie String (stare dane), spróbuj sparsować
    return DateTime.parse(json as String);
  }

  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}

@freezed
abstract class GymClassModel with _$GymClassModel {
  const GymClassModel._();

  const factory GymClassModel({
    required String id,
    required String name,
    required String description,
    required String trainerId,
    @TimestampConverter() required DateTime startTime,
    required int durationMinutes,
    required int capacity,
    @Default([]) List<String> registeredUserIds,
  }) = _GymClassModel;

  factory GymClassModel.fromJson(Map<String, dynamic> json) =>
      _$GymClassModelFromJson(json);

  GymClass toEntity() {
    return GymClass(
      id: id,
      name: name,
      description: description,
      trainerId: trainerId,
      startTime: startTime,
      durationMinutes: durationMinutes,
      capacity: capacity,
      registeredUserIds: registeredUserIds,
    );
  }

  factory GymClassModel.fromEntity(GymClass gymClass) {
    return GymClassModel(
      id: gymClass.id,
      name: gymClass.name,
      description: gymClass.description,
      trainerId: gymClass.trainerId,
      startTime: gymClass.startTime,
      durationMinutes: gymClass.durationMinutes,
      capacity: gymClass.capacity,
      registeredUserIds: gymClass.registeredUserIds,
    );
  }
}
