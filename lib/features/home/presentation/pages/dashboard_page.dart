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
          builder: (context, state) {
            if (state is Authenticated) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Nagłówek powitalny
                    _buildHeader(state.user.firstName),
                    const SizedBox(height: 32),

                    // 2. Najbliższy trening (Hero Widget)
                    _buildSectionTitle("Twój najbliższy trening"),
                    const SizedBox(height: 16),
                    BlocBuilder<ScheduleCubit, ScheduleState>(
                      builder: (context, state) {
                        if (state is ScheduleLoading) {
                          // Zmieniono na spójną wizualnie kartę ładowania (Shimmer effect style)
                          return _buildCardPlaceholder(
                            child: const CircularProgressIndicator(
                              color: Colors.deepPurple,
                            ),
                          );
                        }
                        if (state is ScheduleError) {
                          // Zmieniono na estetyczną kartę błędu z ikoną
                          return _buildCardPlaceholder(
                            color: Colors.red.shade50,
                            borderColor: Colors.red.shade200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade400,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Ups! Coś poszło nie tak.",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Nie udało się załadować treningu.",
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is ScheduleLoaded && state.classes.isEmpty) {
                          // Zmieniono na estetyczną kartę zachęcającą do treningu
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
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                        if (state is ScheduleLoaded) {
                          GymClass firstGymClass = state.classes.first;
                          String trainerName =
                              state.trainerNames[firstGymClass.trainerId] ??
                              "Nieznany trener";
                          return _buildNextTrainingCard(
                            firstGymClass,
                            trainerName,
                          );
                        }
                        // Fallback fallbacku
                        return const SizedBox.shrink();
                      },
                    ),

                    const SizedBox(height: 32),

                    // 3. Szybkie akcje
                    _buildSectionTitle("Na skróty"),
                    const SizedBox(height: 16),
                    _buildQuickActions(),

                    const SizedBox(height: 32),

                    // 4. Motywacja / Statystyki
                    _buildSectionTitle("Twoja aktywność"),
                    const SizedBox(height: 16),
                    _buildActivityCard(),
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

  // NOWY WIDŻET: Ujednolicony wygląd pustych kart
  Widget _buildCardPlaceholder({
    required Widget child,
    Color? color,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      height: 200, // Zbliżona wysokość do fioletowej karty treningu
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor ?? Colors.grey.shade200),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildHeader(String firstName) {
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
          onTap: () {
            context.go('/user');
          },
          customBorder: const CircleBorder(),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.deepPurple.shade100,
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

  Widget _buildNextTrainingCard(GymClass gymClass, String trainerName) {
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
                      "${gymClass.startTime.hour}:${gymClass.startTime.minute.toString().padLeft(2, '0')}", // CZAS
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
            gymClass.name, // NAZWA
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trainerName, // IMIE TRENERA
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

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(Icons.calendar_month, "Grafik", Colors.blue),
        _buildActionItem(Icons.credit_card, "Karnet", Colors.orange),
        _buildActionItem(Icons.history, "Historia", Colors.green),
        _buildActionItem(Icons.more_horiz, "Więcej", Colors.grey.shade700),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color) {
    return Column(
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
    );
  }

  Widget _buildActivityCard() {
    // TODO: Wypełnić te dane w przyszłości
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
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
                  value: 0.75, // Przykładowe 75%
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade100,
                  color: Colors.green,
                  strokeCap: StrokeCap.round,
                ),
              ),
              const Text(
                "3/4",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Świetna robota!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Zrealizowałeś 75% swojego celu treningowego w tym tygodniu.",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
