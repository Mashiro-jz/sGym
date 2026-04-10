import 'package:agym/core/enums/user_role.dart';
import 'package:agym/core/utils/sex_role_extensions.dart';
import 'package:agym/core/utils/user_role_extensions.dart';
import 'package:agym/core/widget/login_out_btn.dart';
import 'package:agym/core/widget/modern_user_avatar.dart';
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

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812);
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _borderColor = const Color(0xFF2A3D2D);
  final Color _textHintColor = const Color(0xFF8B9D90);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! Authenticated) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Center(
          child: Text(
            "Błąd: Nie jesteś zalogowany.",
            style: TextStyle(color: _textHintColor),
          ),
        ),
      );
    }

    final user = authState.user;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          "Twój Profil",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [LoginOutButton(), SizedBox(width: 10)],
      ),
      body: BlocProvider(
        create: (_) => di.sl<ScheduleCubit>()..loadUserClasses(user.id),
        // DODANO: SingleChildScrollView dla całego ekranu profilu
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- CZĘŚĆ GÓRNA: DANE UŻYTKOWNIKA ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Column(
                  children: [
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
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: user.userRole.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: user.userRole.color.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        user.userRole.value.toUpperCase(),
                        style: TextStyle(
                          color: user.userRole.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Przyciski akcji
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (user.userRole == UserRole.manager)
                          _buildActionButton(
                            context: context,
                            icon: Icons.admin_panel_settings_outlined,
                            label: "Panel",
                            onTap: () => context.push('/admin'),
                          ),
                        if (user.userRole == UserRole.trainer)
                          _buildActionButton(
                            context: context,
                            icon: Icons.fitness_center,
                            label: "Trener",
                            onTap: () => context.push('/trainer'),
                          ),
                        _buildActionButton(
                          context: context,
                          icon: Icons.history,
                          label: "Historia",
                          onTap: () => context.push('/history'),
                        ),
                        _buildActionButton(
                          context: context,
                          icon: Icons.settings_outlined,
                          label: "Ustawienia",
                          onTap: () => context.push('/user/settings'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Container(
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _borderColor),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildCompactInfoRow(
                            Icons.email_outlined,
                            user.email,
                          ),
                          Divider(height: 24, color: _borderColor),
                          _buildCompactInfoRow(
                            Icons.phone_outlined,
                            user.phoneNumber,
                          ),
                          Divider(height: 24, color: _borderColor),
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

              const SizedBox(height: 16),

              // --- CZĘŚĆ DOLNA: LISTA TRENINGÓW ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.calendar_month_outlined,
                        size: 16,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Twoje nadchodzące treningi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // USUNIĘTO: Widżet Expanded nie jest potrzebny wewnątrz ScrollView
              BlocConsumer<ScheduleCubit, ScheduleState>(
                listener: (context, state) {
                  if (state is ScheduleOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        backgroundColor: _primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    context.read<ScheduleCubit>().loadUserClasses(user.id);
                  }
                  if (state is ScheduleError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ScheduleLoading) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: CircularProgressIndicator(color: _primaryColor),
                      ),
                    );
                  } else if (state is ScheduleLoaded) {
                    final now = DateTime.now();
                    final upcomingClasses = state.classes
                        .where((c) => c.startTime.isAfter(now))
                        .toList();

                    upcomingClasses.sort(
                      (a, b) => a.startTime.compareTo(b.startTime),
                    );

                    if (upcomingClasses.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      shrinkWrap:
                          true, // Wymagane wewnątrz SingleChildScrollView
                      physics:
                          const NeverScrollableScrollPhysics(), // Wyłącza lokalne przewijanie
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: upcomingClasses.length,
                      itemBuilder: (context, index) {
                        final gymClass = upcomingClasses[index];
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

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: _surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
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
                            highlightColor: _primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            splashColor: _primaryColor.withValues(alpha: 0.15),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // --- LEWA STRONA (Godzina i czas) ---
                                  Container(
                                    width: 85,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            left: Radius.circular(20),
                                          ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          timeStr,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${gymClass.durationMinutes} min",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _textHintColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // --- ŚRODEK (Szczegóły) ---
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            gymClass.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                              color: Colors.white,
                                              letterSpacing: -0.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            dateStr,
                                            style: TextStyle(
                                              color: _textHintColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // --- PRAWA STRONA (Przycisk usuwania) ---
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: _surfaceColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            side: BorderSide(
                                              color: _borderColor,
                                            ),
                                          ),
                                          title: const Text(
                                            "Wypisać się?",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: Text(
                                            "Czy chcesz zrezygnować z zajęć ${gymClass.name}?",
                                            style: TextStyle(
                                              color: _textHintColor,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: Text(
                                                "Nie",
                                                style: TextStyle(
                                                  color: _textHintColor,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                context
                                                    .read<ScheduleCubit>()
                                                    .signOutFromClassActivity(
                                                      gymClass,
                                                    );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors
                                                    .redAccent
                                                    .withValues(alpha: 0.15),
                                                foregroundColor:
                                                    Colors.redAccent,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                "Tak, wypisz",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.redAccent,
                                      size: 26,
                                    ),
                                    tooltip: "Wypisz się",
                                  ),
                                  const SizedBox(width: 8),
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

              // Odstęp zabezpieczający przed wejściem pod Bottom Nav Bar
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- Pomocnicze Widgety ---

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      highlightColor: _primaryColor.withValues(alpha: 0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _surfaceColor,
          border: Border.all(color: _borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: _primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 14,
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
        Icon(icon, size: 20, color: _textHintColor),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: _textHintColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              "Brak zaplanowanych treningów",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Zapisz się w zakładce Grafik!",
              style: TextStyle(color: _textHintColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
