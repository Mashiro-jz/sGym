import 'package:agym/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// 1. Stan początkowy (np. wyświetlamy splash screen)
class AuthInitial extends AuthState {}

// 2. Coś się ładuje (np. kręci się kółeczko)
class AuthLoading extends AuthState {}

// 3. Sukces - Użytkownik jest zalogowany (mamy obiekt User)
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// 4. Użytkownik nie jest zalogowany (Gość)
class Unauthenticated extends AuthState {}

// 5. Wystąpił błąd (np. złe hasło)
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
