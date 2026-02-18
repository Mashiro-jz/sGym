import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/domain/repositories/schedule_repository.dart';

class GetTrainerClasses {
  final ScheduleRepository repository;

  GetTrainerClasses(this.repository);

  Future<List<GymClass>> call(String trainerId) {
    return repository.getTrainerClasses(trainerId);
  }
}
