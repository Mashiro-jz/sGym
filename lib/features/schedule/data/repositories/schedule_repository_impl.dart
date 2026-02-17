import 'package:agym/features/schedule/data/datasources/schedule_remote_data_source.dart';
import 'package:agym/features/schedule/data/models/gym_class_model.dart';
import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource dataSource;

  ScheduleRepositoryImpl({required this.dataSource});

  @override
  Future<void> createClass(GymClass gymClass) {
    final classModel = GymClassModel.fromEntity(gymClass);
    return dataSource.createClass(classModel);
  }

  @override
  Future<void> deleteClass(String classId) {
    return dataSource.deleteClass(classId);
  }

  @override
  Future<List<GymClass>> getSchedule(DateTime date) {
    return dataSource
        .getSchedule(date)
        .then((gymClass) => gymClass.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> updateClass(GymClass gymClass) {
    final classModel = GymClassModel.fromEntity(gymClass);
    return dataSource.updateClass(classModel);
  }
}
