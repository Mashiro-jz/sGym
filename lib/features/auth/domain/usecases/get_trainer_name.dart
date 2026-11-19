import 'package:sgym/features/schedule/domain/repositories/schedule_repository.dart';

class GetTrainerName {
  final ScheduleRepository repository;

  GetTrainerName(this.repository);

  Future<String> call(String trainerId) {
    return repository.getTrainerName(trainerId);
  }
}
