import 'package:sgym/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// 1. Stan poczÄ…tkowy (np. wyĹ›wietlamy splash screen)
class AuthInitial extends AuthState {}

// 2. CoĹ› siÄ™ Ĺ‚aduje (np. krÄ™ci siÄ™ kĂłĹ‚eczko)
class AuthLoading extends AuthState {}

// 3. Sukces - UĹĽytkownik jest zalogowany (mamy obiekt User)
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// 4. UĹĽytkownik nie jest zalogowany (GoĹ›Ä‡)
class Unauthenticated extends AuthState {}

// 5. WystÄ…piĹ‚ bĹ‚Ä…d (np. zĹ‚e hasĹ‚o)
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
