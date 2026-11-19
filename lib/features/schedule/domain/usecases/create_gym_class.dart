import 'package:sgym/features/schedule/domain/entities/gym_class.dart';
import 'package:sgym/features/schedule/domain/repositories/schedule_repository.dart';

class CreateGymClass {
  final ScheduleRepository repository;

  CreateGymClass(this.repository);

  Future<void> call(GymClass gymClass) async {
    if (gymClass.startTime.isBefore(DateTime.now())) {
      throw Exception("Nie moĹĽna utworzyÄ‡ zajÄ™Ä‡ w przeszĹ‚oĹ›ci!");
    }

    await repository.createClass(gymClass);
  }
}
