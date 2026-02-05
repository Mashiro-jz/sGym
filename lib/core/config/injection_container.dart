import 'package:agym/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:agym/features/auth/domain/usecases/get_all_users.dart';
import 'package:agym/features/auth/domain/usecases/update_user_role.dart';
import 'package:agym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Importy naszych warstw (Domeny i Danych)
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ================================================================
  // FEATURES - AUTH
  // ================================================================

  // 1. Use Cases (Logika biznesowa)
  // Rejestrujemy jako 'Factory' - czyli twórz nowego za każdym razem, gdy jest potrzebny.
  sl.registerFactory(() => LoginUser(sl()));
  sl.registerFactory(() => RegisterUser(sl()));
  sl.registerFactory(() => LogoutUser(sl()));
  sl.registerFactory(() => GetCurrentUser(sl()));
  sl.registerFactory(() => UpdateUserRole(sl()));
  sl.registerFactory(() => GetAllUsers(sl()));

  // USER FEATURE
  sl.registerFactory(
    () => AuthCubit(
      loginUser: sl(),
      getCurrentUser: sl(),
      logoutUser: sl(),
      registerUser: sl(),
    ),
  );

  // ADMIN FEATURE
  sl.registerFactory(() => AdminCubit(getAllUsers: sl(), updateUserRole: sl()));

  // 2. Repository (Pośrednik)
  // Rejestrujemy jako 'LazySingleton' - jedna instancja na całe życie aplikacji.
  // Mówimy: "Jak ktoś poprosi o AuthRepository, daj mu AuthRepositoryImpl"
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authRemoteDataSource: sl()),
  );

  // 3. Data Sources (Dane)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firebaseFirestore: sl()),
  );

  // ================================================================
  // EXTERNAL (Zewnętrzne biblioteki)
  // ================================================================

  // Rejestrujemy instancje Firebase, żeby wstrzykiwać je do Data Source.
  // Dzięki temu w testach łatwo je podmienimy na fałszywe.
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
