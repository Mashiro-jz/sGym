import 'package:agym/core/config/app_router.dart';
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
      child: MaterialApp.router(
        title: 'sGym',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        routerConfig: appRouter, // Wstrzykujemy nasz GoRouter
        builder: (context, child) {
          // Główna bramka aplikacji - decyduje, co pokazać w zależności od stanu AuthCubit
          return AuthGate(child: child!);
        },
      ),
    );
  }
}

// BRAMKA (Decyduje jaki ekran pokazać)
class AuthGate extends StatelessWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Logika przekierowań
        if (state is Authenticated) {
          // Jak zalogowany -> idź do Home (który jest wewnątrz ShellRoute)
          appRouter.go('/home');
        } else if (state is Unauthenticated) {
          // Jak niezalogowany -> idź do Login
          appRouter.go('/login');
        }
      },
      child: child, // Wyświetlamy to, co router akurat chce pokazać
    );
  }
}
