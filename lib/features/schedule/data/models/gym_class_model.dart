import 'package:sgym/features/schedule/domain/entities/gym_class.dart';
import 'package:sgym/features/schedule/domain/enums/class_level.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'gym_class_model.freezed.dart';
part 'gym_class_model.g.dart';

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    // JeĹ›li z bazy przyjdzie Timestamp, zamieĹ„ na DateTime
    if (json is Timestamp) return json.toDate();
    // JeĹ›li przyjdzie String (stare dane), sprĂłbuj sparsowaÄ‡
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
    required String category,
    required ClassLevel classLevel,
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
      category: category,
      classLevel: classLevel,
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
      category: gymClass.category,
      classLevel: gymClass.classLevel,
      startTime: gymClass.startTime,
      durationMinutes: gymClass.durationMinutes,
      capacity: gymClass.capacity,
      registeredUserIds: gymClass.registeredUserIds,
    );
  }

  // Usuwa zajÄ™cia, po 15 dniach od rozpoczÄ™cia
  Map<String, dynamic> toFirestore() {
    final map = toJson();

    final expirationDate = startTime.add(const Duration(days: 15));

    map['expireAt'] = Timestamp.fromDate(expirationDate);

    return map;
  }
}
