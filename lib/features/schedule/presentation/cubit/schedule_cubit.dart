import 'package:agym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:agym/features/auth/presentation/cubit/auth_state.dart';
import 'package:agym/features/schedule/domain/usecases/get_user_schedule.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/gym_class.dart';
import '../../domain/usecases/create_gym_class.dart';
import '../../domain/usecases/delete_gym_class.dart';
import '../../domain/usecases/get_schedule.dart';
import '../../domain/usecases/update_gym_class.dart';
import '../../domain/usecases/signout_from_class.dart';
import '../../domain/usecases/signup_for_class.dart';
import 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final CreateGymClass createGymClass;
  final DeleteGymClass deleteGymClass;
  final GetSchedule getSchedule;
  final UpdateGymClass updateGymClass;
  final SignupForClass signUpForClass;
  final SignoutFromClass signOutFromClass;
  final GetUserSchedule getUserSchedule;
  final AuthCubit authCubit;

  DateTime _currentDate = DateTime.now();

  ScheduleCubit({
    required this.createGymClass,
    required this.deleteGymClass,
    required this.getSchedule,
    required this.updateGymClass,
    required this.signUpForClass,
    required this.signOutFromClass,
    required this.authCubit,
    required this.getUserSchedule,
  }) : super(ScheduleInitial());

  // 1. Pobieranie
  Future<void> loadSchedule(DateTime date) async {
    _currentDate = date;
    emit(ScheduleLoading());
    try {
      final classes = await getSchedule(date);
      emit(ScheduleLoaded(classes));
    } catch (e) {
      emit(ScheduleError("Nie udało się pobrać grafiku: $e"));
    }
  }

  // 2. Dodawanie
  Future<void> addClass(GymClass gymClass) async {
    emit(ScheduleLoading());
    try {
      await createGymClass(gymClass);
      emit(const ScheduleOperationSuccess("Dodano nowe zajęcia"));
      loadSchedule(_currentDate);
    } catch (e) {
      emit(ScheduleError("Nie udało się dodać zajęć: $e"));
    }
  }

  // 3. Usuwanie
  Future<void> deleteClass(String classId) async {
    emit(ScheduleLoading());
    try {
      await deleteGymClass(classId);
      emit(const ScheduleOperationSuccess("Usunięto zajęcia"));
      loadSchedule(_currentDate);
    } catch (e) {
      emit(ScheduleError("Nie udało się usunąć zajęć: $e"));
    }
  }

  // 4. Edycja
  Future<void> updateClass(GymClass gymClass) async {
    emit(ScheduleLoading());
    try {
      await updateGymClass(gymClass);
      emit(const ScheduleOperationSuccess("Zaktualizowano zajęcia."));
      loadSchedule(_currentDate);
    } catch (e) {
      emit(ScheduleError("Błąd edycji: $e"));
    }
  }

  Future<void> signUpForClassActivity(GymClass gymClass) async {
    final currentUser = authCubit.state;
    if (currentUser is! Authenticated) return;
    try {
      emit(ScheduleLoading());
      await signUpForClass(gymClass, currentUser.user.id);
      emit(const ScheduleOperationSuccess("Zapisano na zajęcia."));
      loadSchedule(_currentDate);
    } catch (e) {
      emit(ScheduleError("Nie udało się zapisać na zajęcia: $e"));
      loadSchedule(gymClass.startTime);
    }
  }

  Future<void> signOutFromClassActivity(GymClass gymClass) async {
    final currentUser = authCubit.state;
    if (currentUser is! Authenticated) return;
    try {
      emit(ScheduleLoading());
      await signOutFromClass(gymClass, currentUser.user.id);
      emit(const ScheduleOperationSuccess("Wypisano z zajęć."));
      loadSchedule(_currentDate);
    } catch (e) {
      emit(ScheduleError("Nie udało się wypisać z zajęć: $e"));
    }
  }

  Future<void> loadUserClasses(String userId) async {
    emit(ScheduleLoading());
    try {
      final classes = await getUserSchedule(userId);
      emit(ScheduleLoaded(classes));
    } catch (e) {
      emit(ScheduleError("Nie udało się pobrać Twoich zajęć: $e"));
    }
  }
}
