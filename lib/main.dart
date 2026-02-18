import 'package:agym/core/config/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  // 3. Inicjalizacja formatowania dat dla języka polskiego
  await initializeDateFormatting('pl');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. BlocProvider - Wstrzykujemy AuthCubit do całej aplikacji
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()..checkAuthStatus()),
      ],
      child: MaterialApp.router(
        title: 'sGym',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: appRouter,

        // --- SEKJA NAPRAWIAJĄCA BŁĄD KALENDARZA ---
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pl'), // Obsługujemy język polski
        ],

        // -------------------------------------------
        builder: (context, child) {
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
        if (state is Authenticated) {
          // Jeśli jesteśmy na ekranie logowania, a user jest zalogowany -> idź do home
          // Sprawdzamy obecną ścieżkę, żeby nie robić pętli przekierowań
          final location = appRouter.routerDelegate.currentConfiguration.uri
              .toString();
          if (location == '/login' || location == '/register') {
            appRouter.go('/home');
          }
        } else if (state is Unauthenticated) {
          appRouter.go('/login');
        }
      },
      child: child,
    );
  }
}
