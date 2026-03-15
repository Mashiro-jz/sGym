import 'package:agym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:agym/features/auth/presentation/cubit/auth_state.dart';
import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ScheduleDetailsPage extends StatelessWidget {
  final GymClass gymClass;
  final String name; // Imię trenera

  const ScheduleDetailsPage({
    super.key,
    required this.gymClass,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleCubit, ScheduleState>(
      listener: (context, state) {
        if (state is ScheduleOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
              ), // Wiadomość z Cubita ("Zapisano na zajęcia.")
              backgroundColor: Colors.green, // Zielony kolor sukcesu
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ScheduleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red, // Czerwony kolor błędu
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        // Nowoczesny, przezroczysty AppBar
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () {
              // Wracamy na poprzedni ekran używając go_router (lub Navigator.pop)
              if (context.canPop()) {
                context.pop();
              } else {
                // Awaryjny powrót, jeśli z jakiegoś powodu canPop to false
                Navigator.of(context).pop();
              }
            },
          ),
          title: const Text(
            "Szczegóły",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Główna karta z gradientem (Hero)
              _buildHeroCard(),

              const SizedBox(height: 32),

              // 2. Sekcja z Trenerem
              const Text(
                "Prowadzący",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _buildTrainerInfo(),

              const SizedBox(height: 32),

              // 3. Szczegóły (Opis, Intensywność itp.)
              const Text(
                "O zajęciach",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _buildClassDescription(),

              const SizedBox(height: 100), // Miejsce na pływający przycisk
            ],
          ),
        ),

        // 4. Pływający przycisk na samym dole ekranu (Zawsze widoczny)
        bottomSheet: Container(
          color: Colors.grey.shade50,
          padding: const EdgeInsets.all(24.0),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 56,
              // TODO: ZMIENIĆ NAPIS W ZALEŻNOŚCI OD TEGO CZY JEST ZAPISANY CZY NIE
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  if (authState is! Authenticated) {
                    return const SizedBox.shrink();
                  }
                  final currentUserId = authState.user.id;

                  return BlocBuilder<ScheduleCubit, ScheduleState>(
                    builder: (context, scheduleState) {
                      GymClass currentClass = gymClass;
                      if (scheduleState is ScheduleLoaded) {
                        try {
                          currentClass = scheduleState.classes.firstWhere(
                            (c) => c.id == gymClass.id,
                          );
                        } catch (e) {
                          // Ignorujemy, jeśli zajęć z jakiegoś powodu nie ma w nowej puli
                        }
                      }

                      final isEnrolled = currentClass.registeredUserIds
                          .contains(currentUserId); // czy zapisany na zajęcia
                      final isLoading =
                          scheduleState
                              is ScheduleLoading; // czy ładują się zajęcia

                      return ElevatedButton(
                        onPressed: isLoading
                            ? null // Blokujemy przycisk podczas ładowania
                            : () {
                                if (isEnrolled) {
                                  context
                                      .read<ScheduleCubit>()
                                      .signOutFromClassActivity(currentClass);
                                } else {
                                  context
                                      .read<ScheduleCubit>()
                                      .signUpForClassActivity(currentClass);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEnrolled
                              ? Colors.red.shade400
                              : Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: isLoading ? 0 : 5,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEnrolled
                                    ? "Wypisz się z zajęć"
                                    : "Zapisz się na zajęcia",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDŻETY POMOCNICZE ---

  Widget _buildHeroCard() {
    // Formatowanie czasu, by ładnie wyglądał (np. 18:05)
    final timeString =
        "${gymClass.startTime.hour}:${gymClass.startTime.minute.toString().padLeft(2, '0')}";
    // Formatowanie daty (np. 12.10.2023)
    final dateString =
        "${gymClass.startTime.day.toString().padLeft(2, '0')}.${gymClass.startTime.month.toString().padLeft(2, '0')}.${gymClass.startTime.year}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              gymClass.category,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            gymClass.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildHeroIcon(Icons.calendar_today, dateString),
              const SizedBox(width: 20),
              _buildHeroIcon(Icons.access_time, timeString),
              const SizedBox(width: 20),
              _buildHeroIcon(
                Icons.timer_outlined,
                gymClass.durationMinutes.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTrainerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.deepPurple.shade50,
            child: const Icon(Icons.person, color: Colors.deepPurple, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Trener Personalny",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
        ],
      ),
    );
  }

  Widget _buildClassDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gymClass.description,
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(
                "Poziom",
                "Średni",
              ), // TODO: Dynamizuj w przyszłości
              _buildInfoColumn("Spalanie", "~450 kcal"),
              _buildInfoColumn("Sala", "Główna"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
