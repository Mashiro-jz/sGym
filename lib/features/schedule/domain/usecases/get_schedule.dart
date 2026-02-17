import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/domain/repositories/schedule_repository.dart';

class GetSchedule {
  final ScheduleRepository repository;

  GetSchedule(this.repository);

  Future<List<GymClass>> call(DateTime date) async {
    return await repository.getSchedule(date);
  }
}
