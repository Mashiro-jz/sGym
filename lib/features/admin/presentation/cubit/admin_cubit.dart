import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/user_role.dart';
import '../../../auth/domain/usecases/get_all_users.dart';
import '../../../auth/domain/usecases/update_user_role.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final GetAllUsers getAllUsers;
  final UpdateUserRole updateUserRole;

  AdminCubit({required this.getAllUsers, required this.updateUserRole})
    : super(AdminInitial());

  // 1. Pobierz listę wszystkich ludzi
  Future<void> fetchUsers() async {
    emit(AdminLoading());
    try {
      final users = await getAllUsers();
      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminError("Nie udało się pobrać listy: $e"));
    }
  }

  // 2. Zmień rolę użytkownika
  Future<void> updateUserRoleAction({
    required String uid,
    required UserRole newRole,
  }) async {
    // Nie emitujemy Loading, żeby ekran nie mrugał cały czas.
    // Możemy ewentualnie pokazać jakiś pasek ładowania na UI.
    try {
      await updateUserRole(uid: uid, newRole: newRole);

      // Po udanej aktualizacji, odświeżamy listę, żeby widzieć zmiany
      await fetchUsers();
    } catch (e) {
      emit(AdminError("Błąd zmiany roli: $e"));
      // Jeśli błąd, spróbujmy przywrócić listę
      fetchUsers();
    }
  }
}
