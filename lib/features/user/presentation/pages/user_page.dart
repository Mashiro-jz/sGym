import 'package:agym/core/enums/user_role.dart';
import 'package:agym/core/utils/sex_role_extensions.dart';
import 'package:agym/core/utils/user_role_extensions.dart';
import 'package:agym/core/widget/login_out_btn.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/injection_container.dart' as di;
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Sprawdzamy AuthState na samym początku
    final authState = context.watch<AuthCubit>().state;

    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(child: Text("Błąd: Nie jesteś zalogowany.")),
      );
    }

    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Twój Profil"),
        centerTitle: true,
        actions: const [LoginOutButton(), SizedBox(width: 10)],
      ),
      // 2. Wstrzykujemy ScheduleCubit, żeby obsłużyć listę treningów
      body: BlocProvider(
        create: (_) => di.sl<ScheduleCubit>()..loadUserClasses(user.id),
        child: Column(
          children: [
            // --- CZĘŚĆ GÓRNA: DANE UŻYTKOWNIKA (Scrollowalna w razie małego ekranu) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // Awatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Text(
                      user.firstName.isNotEmpty
                          ? user.firstName[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Imię i Nazwisko
                  Text(
                    "${user.firstName} ${user.lastName}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Rola
                  const SizedBox(height: 5),
                  Chip(
                    label: Text(
                      user.userRole.value,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: user.userRole.color,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),

                  const SizedBox(height: 15),

                  // Przyciski akcji (Admin / Ustawienia)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (user.userRole == UserRole.manager) ...[
                        OutlinedButton.icon(
                          onPressed: () => context.push('/admin'),
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text("Panel"),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (user.userRole == UserRole.trainer) ...[
                        OutlinedButton.icon(
                          onPressed: () => context.push('/trainer'),
                          icon: const Icon(Icons.person),
                          label: const Text("Trener"),
                        ),
                        const SizedBox(width: 10),
                      ],
                      OutlinedButton.icon(
                        onPressed: () => context.push('/user/settings'),
                        icon: const Icon(Icons.settings),
                        label: const Text("Ustawienia"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Szczegóły (Email, Telefon) w ładnej karcie
                  Card(
                    elevation: 0,
                    color: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          _buildCompactInfoRow(
                            Icons.email_outlined,
                            user.email,
                          ),
                          const Divider(height: 15),
                          _buildCompactInfoRow(
                            Icons.phone_outlined,
                            user.phoneNumber,
                          ),
                          const Divider(height: 15),
                          _buildCompactInfoRow(
                            Icons.wc,
                            user.sexRole.displayName,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(thickness: 1),

            // --- CZĘŚĆ DOLNA: LISTA TRENINGÓW ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Twoje nadchodzące treningi",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Lista jest Expanded, żeby zajęła resztę ekranu
            Expanded(
              child: BlocConsumer<ScheduleCubit, ScheduleState>(
                listener: (context, state) {
                  if (state is ScheduleOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Po wypisaniu się, odświeżamy listę
                    context.read<ScheduleCubit>().loadUserClasses(user.id);
                  }
                  if (state is ScheduleError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ScheduleLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ScheduleLoaded) {
                    if (state.classes.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      itemCount: state.classes.length,
                      itemBuilder: (context, index) {
                        final gymClass = state.classes[index];
                        // Formatowanie daty: np. "Poniedziałek, 12 Lut • 18:00"
                        final dateStr = DateFormat(
                          'EEEE, d MMM',
                          'pl',
                        ).format(gymClass.startTime);
                        final timeStr = DateFormat(
                          'HH:mm',
                        ).format(gymClass.startTime);

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Lewa strona: Godzina w kółku
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        timeStr,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      Text(
                                        "${gymClass.durationMinutes} min",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.deepPurple.shade300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),

                                // Środek: Nazwa i Data
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        gymClass.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateStr,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Prawa strona: Przycisk Wypisz
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Wypisać się?"),
                                        content: Text(
                                          "Czy chcesz zrezygnować z zajęć ${gymClass.name}?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text("Nie"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              context
                                                  .read<ScheduleCubit>()
                                                  .signOutFromClassActivity(
                                                    gymClass,
                                                  );
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text("Tak, wypisz"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.redAccent,
                                  ),
                                  tooltip: "Wypisz się",
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Pomocnicze Widgety ---

  Widget _buildCompactInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text(
            "Brak zaplanowanych treningów",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 5),
          const Text(
            "Zapisz się w zakładce Grafik!",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
