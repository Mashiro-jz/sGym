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

    // --- PALETA KOLORÓW Z MOCKUPU ---
    final Color bgColor = const Color(0xFF111812);
    final Color textHintColor = const Color(0xFF8B9D90);

    if (authState is! Authenticated) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text(
            "Błąd: Nie jesteś zalogowany.",
            style: TextStyle(color: textHintColor),
          ),
        ),
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

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812);
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _borderColor = const Color(0xFF2A3D2D);
  final Color _textHintColor = const Color(0xFF8B9D90);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          "Zakończone zajęcia",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: _bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return Center(
              child: CircularProgressIndicator(color: _primaryColor),
            );
          }

          if (state is ScheduleError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
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
              padding: const EdgeInsets.all(24.0),
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
    final endTime = gymClass.startTime.add(
      Duration(minutes: gymClass.durationMinutes),
    );
    final endTimeStr = DateFormat('HH:mm').format(endTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(
          20,
        ), // Nieco mocniejsze zaokrąglenie
        border: Border.all(color: _borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- LEWY PANEL (Czas) ---
            Container(
              width: 90,
              color: Colors.black.withValues(
                alpha: 0.2,
              ), // Ciemniejsze wcięcie na czas
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    startTimeStr,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    endTimeStr,
                    style: TextStyle(fontSize: 14, color: _textHintColor),
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gymClass.category,
                      style: TextStyle(color: _textHintColor, fontSize: 13),
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
                    Divider(color: _borderColor, height: 1),
                    const SizedBox(height: 12),

                    // Stopka (Trener i Status)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, size: 14, color: _textHintColor),
                            const SizedBox(width: 4),
                            Text(
                              trainerName,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Zakończone",
                          style: TextStyle(
                            color: _primaryColor, // Neonowy akcent sukcesu!
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: _primaryColor,
          ), // Neonowa ikonka w pigułce
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade300,
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
          Icon(Icons.history_toggle_off, size: 64, color: _textHintColor),
          const SizedBox(height: 16),
          const Text(
            "Historia jest pusta",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Nie masz jeszcze żadnych zakończonych zajęć.",
            style: TextStyle(color: _textHintColor),
          ),
        ],
      ),
    );
  }
}
