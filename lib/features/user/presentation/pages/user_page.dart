import 'package:agym/core/enums/user_role.dart';
import 'package:agym/core/utils/sex_role_extensions.dart';
import 'package:agym/core/utils/user_role_extensions.dart';
import 'package:agym/core/widget/login_out_btn.dart';
import 'package:agym/core/widget/modern_user_avatar.dart'; // Używamy naszego awatara
import 'package:agym/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:agym/features/schedule/presentation/pages/schedule/schedule_details_page.dart';
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
    final authState = context.watch<AuthCubit>().state;

    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(child: Text("Błąd: Nie jesteś zalogowany.")),
      );
    }

    final user = authState.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Twój Profil",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: const [LoginOutButton(), SizedBox(width: 10)],
      ),
      body: BlocProvider(
        create: (_) => di.sl<ScheduleCubit>()..loadUserClasses(user.id),
        child: Column(
          children: [
            // --- CZĘŚĆ GÓRNA: DANE UŻYTKOWNIKA ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                children: [
                  // Używamy nowego, ślicznego Awatara
                  ModernUserAvatar(
                    firstName: user.firstName,
                    lastName: user.lastName,
                    photoUrl: user.photoUrl,
                    radius: 46,
                    fontSize: 32,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "${user.firstName} ${user.lastName}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Ładniejsza pigułka roli
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user.userRole.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.userRole.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Przyciski akcji
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (user.userRole == UserRole.manager) ...[
                        _buildActionButton(
                          context: context,
                          icon: Icons.admin_panel_settings_outlined,
                          label: "Panel",
                          onTap: () => context.push('/admin'),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (user.userRole == UserRole.trainer) ...[
                        _buildActionButton(
                          context: context,
                          icon: Icons.person_outline,
                          label: "Trener",
                          onTap: () => context.push('/trainer'),
                        ),
                        const SizedBox(width: 12),
                      ],
                      _buildActionButton(
                        context: context,
                        icon: Icons.settings_outlined,
                        label: "Ustawienia",
                        onTap: () => context.push('/user/settings'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Szczegóły w jednej czystej karcie
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildCompactInfoRow(Icons.email_outlined, user.email),
                        Divider(height: 24, color: Colors.grey.shade200),
                        _buildCompactInfoRow(
                          Icons.phone_outlined,
                          user.phoneNumber,
                        ),
                        Divider(height: 24, color: Colors.grey.shade200),
                        _buildCompactInfoRow(
                          Icons.person_outline,
                          user.sexRole.displayName,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Nowoczesny separator sekcji (Zamiast chudej kreski)
            Container(
              height: 12,
              width: double.infinity,
              color: Colors.grey.shade50,
            ),

            // --- CZĘŚĆ DOLNA: LISTA TRENINGÓW ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Twoje nadchodzące treningi",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

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
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                      ),
                    );
                  } else if (state is ScheduleLoaded) {
                    if (state.classes.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.classes.length,
                      itemBuilder: (context, index) {
                        final gymClass = state.classes[index];
                        final trainerName =
                            state.trainerNames[gymClass.trainerId] ??
                            "Nieznany trener";
                        final dateStr = DateFormat(
                          'EEEE, d MMM',
                          'pl',
                        ).format(gymClass.startTime);
                        final timeStr = DateFormat(
                          'HH:mm',
                        ).format(gymClass.startTime);

                        // Nowoczesna Karta Treningu
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScheduleDetailsPage(
                                    gymClass: gymClass,
                                    name: trainerName,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Fioletowa pigułka z godziną
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          timeStr,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "${gymClass.durationMinutes} min",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.deepPurple.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          gymClass.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dateStr,
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      // ... Twój istniejący kod Dialogu Wypisywania ...
                                    },
                                    icon: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.remove,
                                        color: Colors.red.shade400,
                                        size: 16,
                                      ),
                                    ),
                                    tooltip: "Wypisz się",
                                  ),
                                ],
                              ),
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

  // Nowy wygląd przycisków akcji (np. Ustawienia)
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
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
          Icon(
            Icons.event_available,
            size: 60,
            color: Colors.deepPurple.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            "Brak zaplanowanych treningów",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Zapisz się w zakładce Grafik!",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
