import 'package:agym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:agym/features/auth/presentation/cubit/auth_state.dart';
import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/config/injection_container.dart' as di;

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(child: Text("Błąd: Nie jesteś zalogowany.")),
      );
    }

    return BlocProvider(
      create: (_) => di.sl<ScheduleCubit>()..loadUserClasses(authState.user.id),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Zakończone zajęcia",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ), // Ciemna strzałka wstecz
      ),
      body: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          if (state is ScheduleError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is ScheduleLoaded) {
            final now = DateTime.now();

            // 1. Filtrujemy tylko zajęcia, które ZAKOŃCZYŁY SIĘ w przeszłości
            final pastClasses = state.classes.where((c) {
              final endTime = c.startTime.add(
                Duration(minutes: c.durationMinutes),
              );
              return endTime.isBefore(now);
            }).toList();

            // 2. Sortujemy malejąco (najświeższe na górze)
            pastClasses.sort((a, b) => b.startTime.compareTo(a.startTime));

            if (pastClasses.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: pastClasses.length,
              itemBuilder: (context, index) {
                final gymClass = pastClasses[index];
                final trainerName =
                    state.trainerNames[gymClass.trainerId] ?? "Trener";

                return _buildHistoryCard(gymClass, trainerName);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- WIERNE ODWZOROWANIE KARTY Z MOCKUPU ---
  Widget _buildHistoryCard(GymClass gymClass, String trainerName) {
    final startTimeStr = DateFormat('HH:mm').format(gymClass.startTime);
    // Obliczamy godzinę zakończenia dodając czas trwania
    final endTime = gymClass.startTime.add(
      Duration(minutes: gymClass.durationMinutes),
    );
    final endTimeStr = DateFormat('HH:mm').format(endTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior:
          Clip.antiAlias, // Ważne, żeby lewy panel nie "wylał" się poza rogi
      child: IntrinsicHeight(
        // Zapewnia, że lewy panel rozciągnie się do pełnej wysokości karty
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- LEWY PANEL (Czas) ---
            Container(
              width: 90,
              color: Colors.grey.shade100, // Jasnoszare tło po lewej
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    startTimeStr,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500, // Szary kolor tekstu
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    endTimeStr,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),

            // --- PRAWY PANEL (Szczegóły) ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gymClass.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gymClass
                          .category, // Zakładam, że kategoria to np. "a2" z mockupu
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pigułki informacyjne
                    Row(
                      children: [
                        _buildChip(
                          Icons.timer_outlined,
                          "${gymClass.durationMinutes} min",
                        ),
                        const SizedBox(width: 8),
                        _buildChip(
                          Icons.people_outline,
                          "${gymClass.registeredUserIds.length} osób",
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade200, height: 1),
                    const SizedBox(height: 12),

                    // Stopka (Trener i Status)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trainerName,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Zakończone",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Historia jest pusta",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Nie masz jeszcze żadnych zakończonych zajęć.",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
