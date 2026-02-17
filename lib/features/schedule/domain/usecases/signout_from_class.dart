import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/domain/repositories/schedule_repository.dart';

class SignoutFromClass {
  final ScheduleRepository repository;

  SignoutFromClass(this.repository);

  Future<void> call(GymClass gymClass, String userId) {
    if (DateTime.now().isAfter(gymClass.startTime)) {
      throw Exception('Cannot sign out from a class that has already started');
    }
    if (!gymClass.registeredUserIds.contains(userId)) {
      throw Exception('User is not registered for this class');
    }

    return repository.signOutFromClass(gymClass.id, userId);
  }
}
