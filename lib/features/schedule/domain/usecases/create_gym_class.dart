import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/domain/repositories/schedule_repository.dart';

class CreateGymClass {
  final ScheduleRepository repository;

  CreateGymClass(this.repository);

  Future<void> call(GymClass gymClass) async {
    if (gymClass.startTime.isBefore(DateTime.now())) {
      throw Exception("Nie można utworzyć zajęć w przeszłości!");
    }

    await repository.createClass(gymClass);
  }
}
