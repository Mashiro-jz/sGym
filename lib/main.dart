import 'package:agym/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/config/injection_container.dart' as di;
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicjalizacja Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Inicjalizacja Dependency Injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. BlocProvider - Wstrzykujemy AuthCubit do całej aplikacji
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          // Tworzymy Cubit i OD RAZU sprawdzamy, czy ktoś jest zalogowany (..checkAuthStatus)
          create: (_) => di.sl<AuthCubit>()..checkAuthStatus(),
        ),
      ],
      child: MaterialApp(
        title: 'sGym',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        // 4. AuthGate - To jest nasza bramka decyzyjna
        home: const AuthGate(),
      ),
    );
  }
}

// BRAMKA (Decyduje jaki ekran pokazać)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // SYTUACJA A: Aplikacja dopiero wstała i sprawdza token w Firebase
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // SYTUACJA B: Mamy użytkownika!
        if (state is Authenticated) {
          // Tu w przyszłości wstawimy prawdziwy HomePage
          return Scaffold(
            appBar: AppBar(
              title: const Text("sGym Home"),
              actions: [
                // Przycisk wylogowania dla testu
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthCubit>().logout();
                  },
                ),
              ],
            ),
            body: Center(
              child: Text("Witaj ${state.user.firstName}! Jesteś zalogowany."),
            ),
          );
        }

        // SYTUACJA C: Nie ma użytkownika (Unauthenticated) lub Błąd
        return const LoginPage();
      },
    );
  }
}
