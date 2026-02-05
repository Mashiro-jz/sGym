import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

// Stan sukcesu - mamy listę użytkowników do wyświetlenia
class AdminUsersLoaded extends AdminState {
  final List<User> users;

  const AdminUsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object> get props => [message];
}
