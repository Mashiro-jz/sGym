import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:agym/features/schedule/presentation/pages/schedule/schedule_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812);
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _borderColor = const Color(0xFF2A3D2D);
  final Color _textHintColor = const Color(0xFF8B9D90);

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<ScheduleCubit>().loadUserClasses(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // TODO: Otwarcie bocznego menu (jeśli planujesz)
          },
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Powitanie
                    _buildHeader(context, authState.user.firstName),
                    const SizedBox(height: 32),

                    BlocBuilder<ScheduleCubit, ScheduleState>(
                      builder: (context, scheduleState) {
                        List<GymClass> userClasses = [];
                        if (scheduleState is ScheduleLoaded) {
                          userClasses = scheduleState.classes;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 2. Najbliższy trening (Główna Karta)
                            _buildNextTrainingSection(context, scheduleState),
                            const SizedBox(height: 32),

                            // 3. Szybkie akcje
                            _buildSectionTitle("Na skróty"),
                            const SizedBox(height: 16),
                            _buildQuickActions(context),
                            const SizedBox(height: 32),

                            // 4. Progres / Statystyki
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionTitle("Twój postęp"),
                                TextButton(
                                  onPressed: () => context.push('/history'),
                                  child: Text(
                                    "Zobacz",
                                    style: TextStyle(
                                      color: _primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildActivityCard(userClasses),
                            const SizedBox(height: 32),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(color: _primaryColor),
            );
          },
        ),
      ),
    );
  }

  // --- WIDŻETY POMOCNICZE ---

  Widget _buildHeader(BuildContext context, String firstName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cześć, $firstName! 👋",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Gotowy na dzisiejszy wycisk?",
          style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildNextTrainingSection(BuildContext context, ScheduleState state) {
    if (state is ScheduleLoading) {
      return _buildCardPlaceholder(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    if (state is ScheduleError) {
      return _buildCardPlaceholder(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 40),
            const SizedBox(height: 12),
            const Text(
              "Ups! Coś poszło nie tak.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (state is ScheduleLoaded) {
      final now = DateTime.now();
      final upcomingClasses = state.classes
          .where((c) => c.startTime.isAfter(now))
          .toList();

      if (upcomingClasses.isEmpty) {
        return _buildCardPlaceholder(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.weekend_outlined, color: _textHintColor, size: 48),
              const SizedBox(height: 16),
              const Text(
                "Wolny dzień!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Odpoczywaj lub zapisz się na zajęcia.",
                style: TextStyle(color: Colors.grey.shade400),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      upcomingClasses.sort((a, b) => a.startTime.compareTo(b.startTime));
      final firstGymClass = upcomingClasses.first;
      final trainerName =
          state.trainerNames[firstGymClass.trainerId] ?? "Nieznany trener";

      return _buildNextTrainingCard(context, firstGymClass, trainerName);
    }
    return const SizedBox.shrink();
  }

  Widget _buildCardPlaceholder({required Widget child}) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor),
      ),
      child: Center(child: child),
    );
  }

  // GŁÓWNA KARTA (Zainspirowana "Live Status" z mockupu)
  Widget _buildNextTrainingCard(
    BuildContext context,
    GymClass gymClass,
    String trainerName,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etykieta statusu
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "NAJBLIŻSZY TRENING",
                style: TextStyle(
                  color: _textHintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            gymClass.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.person_outline, color: _primaryColor, size: 16),
              const SizedBox(width: 4),
              Text(
                trainerName,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, color: _primaryColor, size: 16),
              const SizedBox(width: 4),
              Text(
                "${gymClass.startTime.hour}:${gymClass.startTime.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Neonowy przycisk
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
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
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Szczegóły",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          Icons.calendar_month,
          "Grafik",
          () => context.go('/schedule'),
        ),
        _buildActionItem(Icons.qr_code, "Karnet", () => context.go('/pass')),
        _buildActionItem(
          Icons.fitness_center,
          "Trenerzy",
          () {},
        ), // Przykład nowej akcji
        _buildActionItem(
          Icons.person_outline,
          "Profil",
          () => context.go('/user'),
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _borderColor),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // --- KARTA AKTYWNOŚCI ---
  Widget _buildActivityCard(List<GymClass> classes) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final monday = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59));

    final weeklyClasses = classes
        .where(
          (c) => c.startTime.isAfter(monday) && c.startTime.isBefore(sunday),
        )
        .toList();
    final int currentScore = weeklyClasses.length;
    const int targetGoal = 4;

    double progress = currentScore / targetGoal;
    if (progress > 1.0) progress = 1.0;

    String title = "Zaczynamy!";
    String subtitle = "Zapisz się na pierwszy trening.";

    if (currentScore >= targetGoal) {
      title = "Cel osiągnięty!";
      subtitle = "Jesteś nie do zatrzymania!";
    } else if (currentScore > 0) {
      title = "Dobry start!";
      subtitle = "Wykonano ${(progress * 100).toInt()}% planu tygodniowego.";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: _bgColor,
                  color: _primaryColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                "$currentScore/$targetGoal",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
