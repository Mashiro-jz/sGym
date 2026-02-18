import 'package:agym/features/auth/domain/usecases/get_users_details.dart';
import 'package:agym/features/schedule/domain/usecases/get_trainer_classes.dart';
import 'package:agym/features/schedule/domain/usecases/get_user_schedule.dart';
import 'package:agym/features/schedule/domain/usecases/signout_from_class.dart';
import 'package:agym/features/schedule/domain/usecases/signup_for_class.dart';
import 'package:agym/features/schedule/presentation/cubit/class_participants_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/trainer_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/delete_account.dart';
import '../../features/auth/domain/usecases/get_all_users.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/update_user_data.dart';
import '../../features/auth/domain/usecases/update_user_role.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/user/presentation/cubit/user_cubit.dart';
import '../../features/admin/presentation/cubit/admin_cubit.dart';
import '../../features/schedule/data/datasources/schedule_remote_data_source.dart';
import '../../features/schedule/data/repositories/schedule_repository_impl.dart';
import '../../features/schedule/domain/repositories/schedule_repository.dart';
import '../../features/schedule/domain/usecases/create_gym_class.dart';
import '../../features/schedule/domain/usecases/delete_gym_class.dart';
import '../../features/schedule/domain/usecases/get_schedule.dart';
import '../../features/schedule/domain/usecases/update_gym_class.dart';
import '../../features/schedule/presentation/cubit/schedule_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ================================================================
  // EXTERNAL
  // ================================================================
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // ================================================================
  // FEATURE: AUTH & USER
  // ================================================================

  // Cubits
  sl.registerLazySingleton(
    () => AuthCubit(
      loginUser: sl(),
      getCurrentUser: sl(),
      logoutUser: sl(),
      registerUser: sl(),
    ),
  );

  sl.registerFactory(
    () => UserCubit(updateUserData: sl(), deleteAccount: sl()),
  );
  sl.registerFactory(() => AdminCubit(getAllUsers: sl(), updateUserRole: sl()));
  sl.registerFactory(() => TrainerCubit(getTrainerClasses: sl()));

  // Use Cases
  sl.registerFactory(() => LoginUser(sl()));
  sl.registerFactory(() => RegisterUser(sl()));
  sl.registerFactory(() => LogoutUser(sl()));
  sl.registerFactory(() => GetCurrentUser(sl()));
  sl.registerFactory(() => UpdateUserData(sl()));
  sl.registerFactory(() => DeleteAccount(sl()));
  sl.registerFactory(() => UpdateUserRole(sl()));
  sl.registerFactory(() => GetAllUsers(sl()));
  sl.registerFactory(() => GetUsersDetails(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authRemoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firebaseFirestore: sl()),
  );

  // ================================================================
  // FEATURE: SCHEDULE
  // ================================================================

  // Cubit
  sl.registerFactory(
    () => ScheduleCubit(
      createGymClass: sl(),
      deleteGymClass: sl(),
      getSchedule: sl(),
      updateGymClass: sl(),
      signUpForClass: sl(),
      signOutFromClass: sl(),
      authCubit: sl(),
      getUserSchedule: sl(),
    ),
  );
  sl.registerFactory(() => ClassParticipantsCubit(getUsersDetails: sl()));

  // Use Cases
  sl.registerFactory(() => GetSchedule(sl()));
  sl.registerFactory(() => CreateGymClass(sl()));
  sl.registerFactory(() => DeleteGymClass(sl()));
  sl.registerFactory(() => UpdateGymClass(sl()));
  sl.registerFactory(() => SignupForClass(sl()));
  sl.registerFactory(() => SignoutFromClass(sl()));
  sl.registerFactory(() => GetUserSchedule(sl()));
  sl.registerFactory(() => GetTrainerClasses(sl()));

  // Repository
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(dataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<ScheduleRemoteDataSource>(
    () => ScheduleRemoteDataSourceImpl(firebaseFirestore: sl()),
  );
}
