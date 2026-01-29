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
}
