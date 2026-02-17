import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/domain/repositories/schedule_repository.dart';

class UpdateGymClass {
  final ScheduleRepository repository;

  UpdateGymClass(this.repository);

  Future<void> call(GymClass gymClass) async {
    await repository.updateClass(gymClass);
  }
}
