import 'package:sgym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sgym/features/auth/presentation/cubit/auth_state.dart';
import 'package:sgym/features/auth/domain/usecases/get_trainer_name.dart';
import 'package:sgym/features/schedule/domain/usecases/get_user_schedule.dart';
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
  final GetTrainerName getTrainerName;
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
    required this.getTrainerName,
  }) : super(ScheduleInitial());

  // 1. Pobieranie
  Future<void> loadSchedule(DateTime date) async {
    _currentDate = date;
    emit(ScheduleLoading());
    try {
      final classes = await getSchedule(date);
      Map<String, String> trainersName = {};
      for (var scheduleClass in classes) {
        if (!trainersName.containsKey(scheduleClass.trainerId)) {
          trainersName[scheduleClass.trainerId] = await getTrainerName(
            scheduleClass.trainerId,
          );
        }
      }

      emit(ScheduleLoaded(classes, trainersName));
    } catch (e) {
      emit(ScheduleError("Nie udaĹ‚o siÄ™ pobraÄ‡ grafiku: $e"));
    }
  }

  // 2. Dodawanie
  Future<void> addClass(GymClass gymClass) async {
    emit(ScheduleLoading());
    try {
      await createGymClass(gymClass);
      emit(const ScheduleOperationSuccess("Dodano nowe zajÄ™cia"));
      loadSchedule(_currentDate);
    } catch (e) {
      emit(ScheduleError("Nie udaĹ‚o siÄ™ dodaÄ‡ zajÄ™Ä‡: $e"));
    }
  }

  // 3. Usuwanie
  Future<void> deleteClass(String classId) async {
    emit(ScheduleLoading());
    try {
      await deleteGymClass(classId);
      emit(const ScheduleOperationSuccess("UsuniÄ™to zajÄ™cia"));
      loadSchedule(_currentDate);
    } catch (e) {
      emit(ScheduleError("Nie udaĹ‚o siÄ™ usunÄ…Ä‡ zajÄ™Ä‡: $e"));
    }
  }

  // 4. Edycja
  Future<void> updateClass(GymClass gymClass) async {
    emit(ScheduleLoading());
    try {
      await updateGymClass(gymClass);
      emit(const ScheduleOperationSuccess("Zaktualizowano zajÄ™cia."));
      loadSchedule(_currentDate);
    } catch (e) {
      emit(ScheduleError("BĹ‚Ä…d edycji: $e"));
    }
  }

  Future<void> signUpForClassActivity(GymClass gymClass) async {
    final currentUser = authCubit.state;
    if (currentUser is! Authenticated) return;
    try {
      emit(ScheduleLoading());
      await signUpForClass(gymClass, currentUser.user.id);
      emit(const ScheduleOperationSuccess("Zapisano na zajÄ™cia."));

      // POPRAWKA: UĹĽywamy dokĹ‚adnej daty modyfikowanych zajÄ™Ä‡!
      await loadSchedule(gymClass.startTime);
    } catch (e) {
      emit(ScheduleError("Nie udaĹ‚o siÄ™ zapisaÄ‡ na zajÄ™cia: $e"));
      await loadSchedule(gymClass.startTime);
    }
  }

  Future<void> signOutFromClassActivity(GymClass gymClass) async {
    final currentUser = authCubit.state;
    if (currentUser is! Authenticated) return;
    try {
      emit(ScheduleLoading());
      await signOutFromClass(gymClass, currentUser.user.id);
      emit(const ScheduleOperationSuccess("Wypisano z zajÄ™Ä‡."));

      await loadSchedule(gymClass.startTime);
    } catch (e) {
      emit(ScheduleError("Nie udaĹ‚o siÄ™ wypisaÄ‡ z zajÄ™Ä‡: $e"));
      await loadSchedule(gymClass.startTime);
    }
  }

  Future<void> loadUserClasses(String userId) async {
    emit(ScheduleLoading());
    try {
      final classes = await getUserSchedule(userId);
      Map<String, String> trainersName = {};
      for (var scheduleClass in classes) {
        if (!trainersName.containsKey(scheduleClass.trainerId)) {
          trainersName[scheduleClass.trainerId] = await getTrainerName(
            scheduleClass.trainerId,
          );
        }
      }

      emit(ScheduleLoaded(classes, trainersName));
    } catch (e) {
      emit(ScheduleError("Nie udaĹ‚o siÄ™ pobraÄ‡ Twoich zajÄ™Ä‡: $e"));
    }
  }
}
