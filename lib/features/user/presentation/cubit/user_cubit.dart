import 'package:agym/core/enums/sex_role.dart';
import 'package:agym/features/auth/domain/usecases/update_user_data.dart';
import 'package:agym/features/user/presentation/cubit/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserCubit extends Cubit<UserState> {
  final UpdateUserData updateUserData;

  UserCubit({required this.updateUserData}) : super(UserInitial());

  // Funkcja do aktualizacji danych użytkownika
  Future<void> submitUserDataUpdate({
    required String uid,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    String? photoUrl,
    required SexRole sexRole,
  }) async {
    emit(UserLoading());
    try {
      await updateUserData(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        email: email,
        photoUrl: photoUrl,
        sexRole: sexRole,
      ).timeout(const Duration(seconds: 10));
      emit(UserDataUpdateSuccess());
    } catch (e) {
      emit(UserError("Nie udało się zaktualizować danych: $e"));
    }
  }
}
