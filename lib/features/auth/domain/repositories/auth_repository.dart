import 'package:agym/core/enums/sex_role.dart';
import 'package:agym/core/enums/user_role.dart';

import '../entities/user.dart';

// To jest klasa abstrakcyjna - czyli lista wymagań.
// Każdy mechanizm logowania (np. Firebase) musi spełniać te wymagania.

abstract class AuthRepository {
  // Logowanie: Wymaga e-maila i hasła, zwraca Użytkownika (Entity)
  Future<User> login({required String email, required String password});

  // Rejestracja: Wymaga e-maila, hasła i danych użytkownika (imie, rola itp.)
  // Zwraca utworzonego użytkownika.
  Future<User> register({
    required String email,
    required String password,
    required User user, // Przekazujemy tu obiekt z imieniem, rolą itp.
  });

  // Wylogowanie
  Future<void> logout();

  // Sprawdzenie: Czy ktoś jest już zalogowany? (np. po restarcie apki)
  // Zwraca User lub null (jeśli nikt nie jest zalogowany).
  Future<User?> getCurrentUser();

  Future<List<User>> getAllUsers();
  Future<void> updateUserRole({required String uid, required UserRole newRole});

  Future<void> updateUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    String? photoUrl,
    required SexRole sexRole,
  });

  Future<void> deleteAccount(String password);

  Future<List<User>> getUsersDetails(List<String> uids);
}
