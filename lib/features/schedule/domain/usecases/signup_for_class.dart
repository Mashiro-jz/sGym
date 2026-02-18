import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/domain/repositories/schedule_repository.dart';

class SignupForClass {
  final ScheduleRepository repository;

  SignupForClass(this.repository);

  Future<void> call(GymClass gymClass, String userId) {
    if (gymClass.registeredUserIds.contains(userId)) {
      throw Exception('User is already registered for this class');
    }
    if (DateTime.now().isAfter(gymClass.startTime)) {
      throw Exception('Cannot sign up for a class that has already started');
    }
    if (gymClass.registeredUserIds.length >= gymClass.capacity) {
      throw Exception('Class is already full');
    }

    return repository.signUpForClass(gymClass.id, userId);
  }
}
