import '../entities/gym_class.dart';
import '../repositories/schedule_repository.dart';

class GetUserSchedule {
  final ScheduleRepository repository;

  GetUserSchedule(this.repository);

  Future<List<GymClass>> call(String userId) {
    return repository.getUserSchedule(userId);
  }
}
