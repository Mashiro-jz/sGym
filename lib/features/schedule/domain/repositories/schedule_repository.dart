import 'package:agym/features/schedule/domain/entities/gym_class.dart';

abstract class ScheduleRepository {
  Future<List<GymClass>> getSchedule(DateTime date);

  Future<void> createClass(GymClass gymClass);

  Future<void> updateClass(GymClass gymClass);

  Future<void> deleteClass(String classId);

  Future<void> signUpForClass(String classId, String userId);

  Future<void> signOutFromClass(String classId, String userId);

  Future<List<GymClass>> getUserSchedule(String userId);
}
