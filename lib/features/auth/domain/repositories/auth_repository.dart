import 'package:sgym/core/enums/sex_role.dart';
import 'package:sgym/core/enums/user_role.dart';

import '../entities/user.dart';

// To jest klasa abstrakcyjna - czyli lista wymagaĹ„.
// KaĹĽdy mechanizm logowania (np. Firebase) musi speĹ‚niaÄ‡ te wymagania.

abstract class AuthRepository {
  // Logowanie: Wymaga e-maila i hasĹ‚a, zwraca UĹĽytkownika (Entity)
  Future<User> login({required String email, required String password});

  // Rejestracja: Wymaga e-maila, hasĹ‚a i danych uĹĽytkownika (imie, rola itp.)
  // Zwraca utworzonego uĹĽytkownika.
  Future<User> register({
    required String email,
    required String password,
    required User user, // Przekazujemy tu obiekt z imieniem, rolÄ… itp.
  });

  // Wylogowanie
  Future<void> logout();

  // Sprawdzenie: Czy ktoĹ› jest juĹĽ zalogowany? (np. po restarcie apki)
  // Zwraca User lub null (jeĹ›li nikt nie jest zalogowany).
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
