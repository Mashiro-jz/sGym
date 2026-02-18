import 'package:agym/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

abstract class ClassParticipantsState extends Equatable {
  const ClassParticipantsState();

  @override
  List<Object?> get props => [];
}

class ClassParticipantsInitial extends ClassParticipantsState {}

class ClassParticipantsLoading extends ClassParticipantsState {}

class ClassParticipantsLoaded extends ClassParticipantsState {
  final List<User> participants;

  const ClassParticipantsLoaded(this.participants);

  @override
  List<Object?> get props => [participants];
}

class ClassParticipantsError extends ClassParticipantsState {
  final String message;

  const ClassParticipantsError(this.message);

  @override
  List<Object?> get props => [message];
}
