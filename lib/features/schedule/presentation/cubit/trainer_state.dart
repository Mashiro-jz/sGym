import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:equatable/equatable.dart';

abstract class TrainerState extends Equatable {
  const TrainerState();

  @override
  List<Object?> get props => [];
}

class TrainerInitial extends TrainerState {}

class TrainerLoading extends TrainerState {}

class TrainerLoaded extends TrainerState {
  final List<GymClass> classes;

  const TrainerLoaded(this.classes);

  @override
  List<Object?> get props => [classes];
}

class TrainerError extends TrainerState {
  final String message;

  const TrainerError(this.message);

  @override
  List<Object?> get props => [message];
}
