import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:equatable/equatable.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<GymClass> classes;
  final Map<String, String> trainerNames;

  const ScheduleLoaded(this.classes, this.trainerNames);

  @override
  List<Object?> get props => [classes, trainerNames];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}

class ScheduleOperationSuccess extends ScheduleState {
  final String message;

  const ScheduleOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
