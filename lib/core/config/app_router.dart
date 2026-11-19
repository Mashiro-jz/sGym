import 'package:sgym/features/admin/presentation/pages/admin_page.dart';
import 'package:sgym/features/home/presentation/pages/dashboard_page.dart';
import 'package:sgym/features/schedule/domain/entities/gym_class.dart';
import 'package:sgym/features/schedule/presentation/pages/history/history_page.dart';
import 'package:sgym/features/schedule/presentation/pages/schedule/add_edit_class_page.dart';
import 'package:sgym/features/schedule/presentation/pages/schedule/schedule_page.dart';
import 'package:sgym/features/schedule/presentation/pages/trainer/trainer_page.dart';
import 'package:sgym/features/user/presentation/pages/user_settings_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/main_wrapper.dart';
import '../../features/user/presentation/pages/user_page.dart';
import '../../features/pass/presentation/pages/pass_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    // === POZIOM 0: Ekrany BEZ menu dolnego ===
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    // === POZIOM 1: Ekrany Z menu dolnym (Shell) ===
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainWrapper(child: child);
      },
      routes: [
        // ZakĹ‚adka 1: Home
        GoRoute(
          path: '/home',
          builder: (context, state) => const DashboardView(),
        ),
        GoRoute(path: '/pass', builder: (context, state) => const PassPage()),
        // ZakĹ‚adka 2: Profil
        GoRoute(
          path: '/user',
          builder: (context, state) => const UserProfile(),
        ),
        GoRoute(path: '/admin', builder: (context, state) => const AdminPage()),
        GoRoute(
          path: '/trainer',
          builder: (context, state) => const TrainerPage(),
        ),
        GoRoute(
          path: '/user/settings',
          builder: (context, state) => const ProfileSettingsPage(),
        ),
        // ZakĹ‚adka 3: Grafik zajÄ™Ä‡
        GoRoute(
          path: '/schedule',
          builder: (context, state) => const SchedulePage(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryPage(),
        ),
        GoRoute(
          path: '/add-edit-class',
          builder: (context, state) {
            // Odbieramy obiekt przekazany przy nawigacji (moĹĽe byÄ‡ null)
            final gymClass = state.extra as GymClass?;
            return AddEditClassPage(gymClass: gymClass);
          },
        ),
      ],
    ),
  ],
);
