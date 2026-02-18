import 'package:agym/features/schedule/domain/repositories/schedule_repository.dart';

class DeleteGymClass {
  final ScheduleRepository repository;

  DeleteGymClass(this.repository);

  Future<void> call(String classId) async {
    await repository.deleteClass(classId);
  }
}
