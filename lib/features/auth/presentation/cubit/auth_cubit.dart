import 'package:agym/features/auth/domain/entities/user.dart';
import 'package:agym/features/auth/domain/usecases/get_current_user.dart';
import 'package:agym/features/auth/domain/usecases/login_user.dart';
import 'package:agym/features/auth/domain/usecases/logout_user.dart';
import 'package:agym/features/auth/domain/usecases/register_user.dart';
import 'package:agym/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUser loginUser;
  final GetCurrentUser getCurrentUser;
  final LogoutUser logoutUser;
  final RegisterUser registerUser;

  AuthCubit({
    required this.loginUser,
    required this.getCurrentUser,
    required this.logoutUser,
    required this.registerUser,
  }) : super(AuthInitial());

  // Funkcja 1: Sprawdź na starcie, czy ktoś jest zalogowany
  Future<void> checkAuthStatus() async {
    try {
      final user = await getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Funkcja 2: Logowanie
  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final user = await loginUser(email: email, password: password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Funkcja 3: Rejestracja
  Future<void> register({
    required String email,
    required String password,
    required User user,
  }) async {
    emit(AuthLoading());
    try {
      final newUser = await registerUser(
        email: email,
        password: password,
        user: user,
      );

      emit(Authenticated(newUser));
    } catch (e) {
      emit(AuthError("Nie udało się zarejestrować: $e"));
    }
  }

  // Funkcja 4: Rejestracja
  Future<void> logout() async {
    await logoutUser();
    emit(Unauthenticated());
  }
}
