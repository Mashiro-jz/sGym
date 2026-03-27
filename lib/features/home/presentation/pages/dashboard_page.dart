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
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Nagłówek powitalny
                    _buildHeader(context, authState.user.firstName),
                    const SizedBox(height: 32),

                    // Obejmujemy resztę ekranu w BlocBuilder, by wszystkie karty miały dostęp do danych
                    BlocBuilder<ScheduleCubit, ScheduleState>(
                      builder: (context, scheduleState) {
                        // Pobieramy listę zajęć, jeśli są załadowane (w przeciwnym razie pusta lista)
                        List<GymClass> userClasses = [];
                        if (scheduleState is ScheduleLoaded) {
                          userClasses = scheduleState.classes;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 2. Najbliższy trening
                            _buildSectionTitle("Twój najbliższy trening"),
                            const SizedBox(height: 16),
                            _buildNextTrainingSection(context, scheduleState),

                            const SizedBox(height: 32),

                            // 3. Szybkie akcje (Podpięty routing!)
                            _buildSectionTitle("Na skróty"),
                            const SizedBox(height: 16),
                            _buildQuickActions(context),

                            const SizedBox(height: 32),

                            // 4. Motywacja / Statystyki (TUTAJ DZIEJE SIĘ MAGIA)
                            _buildSectionTitle("Twoja aktywność"),
                            const SizedBox(height: 16),
                            _buildActivityCard(userClasses),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  // --- WIDŻETY POMOCNICZE ---

  Widget _buildNextTrainingSection(BuildContext context, ScheduleState state) {
    if (state is ScheduleLoading) {
      return _buildCardPlaceholder(
        child: const CircularProgressIndicator(color: Colors.deepPurple),
      );
    }

    if (state is ScheduleError) {
      return _buildCardPlaceholder(
        color: Colors.red.shade50,
        borderColor: Colors.red.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 40),
            const SizedBox(height: 12),
            const Text(
              "Ups! Coś poszło nie tak.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Nie udało się załadować treningu.",
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is ScheduleLoaded) {
      // Szukamy najbliższych nadchodzących zajęć
      final now = DateTime.now();
      final upcomingClasses = state.classes
          .where((c) => c.startTime.isAfter(now))
          .toList();

      if (upcomingClasses.isEmpty) {
        return _buildCardPlaceholder(
          color: Colors.white,
          borderColor: Colors.grey.shade300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.weekend_outlined,
                color: Colors.grey.shade400,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                "Wolny dzień!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Nie masz dziś w planach żadnego wycisku. Odpoczywaj lub zapisz się na zajęcia!",
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      // Sortujemy, żeby pokazać najbliższe na samej górze
      upcomingClasses.sort((a, b) => a.startTime.compareTo(b.startTime));
      final firstGymClass = upcomingClasses.first;
      final trainerName =
          state.trainerNames[firstGymClass.trainerId] ?? "Nieznany trener";

      return _buildNextTrainingCard(context, firstGymClass, trainerName);
    }

    return const SizedBox.shrink();
  }

  Widget _buildCardPlaceholder({
    required Widget child,
    Color? color,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor ?? Colors.grey.shade200),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildHeader(BuildContext context, String firstName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cześć, $firstName! 👋",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Gotowy na dzisiejszy wycisk?",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
        InkWell(
          onTap: () => context.go('/user'),
          customBorder: const CircleBorder(),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.deepPurple.shade50,
            child: const Icon(Icons.person, color: Colors.deepPurple, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildNextTrainingCard(
    BuildContext context,
    GymClass gymClass,
    String trainerName,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 16,
                    ),
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
              ),
              const Icon(Icons.fitness_center, color: Colors.white54, size: 32),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            gymClass.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trainerName,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
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
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Szczegóły treningu",
                style: TextStyle(fontWeight: FontWeight.bold),
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
          Colors.blue,
          () => context.go('/schedule'),
        ),
        _buildActionItem(
          Icons.credit_card,
          "Karnet",
          Colors.orange,
          () => context.go('/pass'),
        ),
        _buildActionItem(
          Icons.history,
          "Historia",
          Colors.green,
          () => context.push('/history'),
        ), // Tu kieruje do historii
        _buildActionItem(
          Icons.more_horiz,
          "Więcej",
          Colors.grey.shade700,
          () => context.go('/user'),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // --- DYNAMICZNA KARTA AKTYWNOŚCI ---
  Widget _buildActivityCard(List<GymClass> classes) {
    // 1. Znajdujemy granice obecnego tygodnia (Poniedziałek - Niedziela)
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final monday = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59));

    // 2. Filtrujemy zajęcia, które odbywają/odbyły się w tym tygodniu
    final weeklyClasses = classes
        .where(
          (c) => c.startTime.isAfter(monday) && c.startTime.isBefore(sunday),
        )
        .toList();

    final int currentScore =
        weeklyClasses.length; // TODO: targetGoal zmienić z czasem
    const int targetGoal = 4; // Nasz domyślny cel (np. 4 treningi w tygodniu)

    // 3. Zabezpieczenie przed ułamkami większymi niż 1.0
    double progress = currentScore / targetGoal;
    if (progress > 1.0) progress = 1.0;

    // 4. Dynamiczna zmiana tekstów na podstawie wyniku
    String title = "Czas zacząć!";
    String subtitle = "Zapisz się na pierwszy trening w tym tygodniu.";
    Color progressColor = Colors.orange;

    if (currentScore >= targetGoal) {
      title = "Niesamowite!";
      subtitle = "Zrealizowałeś 100% swojego celu na ten tydzień!";
      progressColor = Colors.green;
    } else if (currentScore > 0) {
      title = "Dobry start!";
      subtitle =
          "Zrealizowałeś ${(progress * 100).toInt()}% swojego celu treningowego.";
      progressColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  backgroundColor: Colors.grey.shade100,
                  color: progressColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                "$currentScore/$targetGoal",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
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
