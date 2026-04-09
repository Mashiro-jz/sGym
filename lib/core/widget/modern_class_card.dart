import 'package:agym/core/widget/modern_class_info.dart';
import 'package:agym/core/widget/modern_class_userbtn.dart';
import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:agym/features/schedule/presentation/pages/schedule/schedule_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ModernClassCard extends StatelessWidget {
  final GymClass gymClass;
  final String trainerName;
  final bool isTrainer;
  final String currentUserId;
  final DateTime selectedDate;

  const ModernClassCard({
    super.key,
    required this.gymClass,
    required this.trainerName,
    required this.isTrainer,
    required this.currentUserId,
    required this.selectedDate,
  });

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _borderColor = const Color(0xFF2A3D2D);
  final Color _textHintColor = const Color(0xFF8B9D90);

  void _deleteClass(BuildContext context, String classId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surfaceColor, // Ciemne tło dialogu
        title: const Text(
          "Usuń zajęcia",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Nie będzie można tego cofnąć.",
          style: TextStyle(color: _textHintColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Anuluj", style: TextStyle(color: _textHintColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ScheduleCubit>().deleteClass(classId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text(
              "Usuń",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startTimeStr = DateFormat('HH:mm').format(gymClass.startTime);
    final endTimeStr = DateFormat('HH:mm').format(
      gymClass.startTime.add(Duration(minutes: gymClass.durationMinutes)),
    );

    final isRegistered = gymClass.registeredUserIds.contains(currentUserId);
    final isFull = gymClass.registeredUserIds.length >= gymClass.capacity;
    final hasStarted = DateTime.now().isAfter(gymClass.startTime);
    final placesLeft = gymClass.capacity - gymClass.registeredUserIds.length;

    return InkWell(
      onTap: () {
        final currentScheduleCubit = context.read<ScheduleCubit>();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: currentScheduleCubit,
              child: ScheduleDetailsPage(gymClass: gymClass, name: trainerName),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20), // Zaokrąglenie efektu tapnięcia
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isRegistered
                  ? _primaryColor.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: isRegistered ? 15 : 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isRegistered
              ? Border.all(
                  color: _primaryColor.withValues(alpha: 0.6),
                  width: 1.5,
                )
              : Border.all(color: _borderColor),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- LEWA STRONA: CZAS ---
              Container(
                width: 85, // Nieco szerszy dla lepszych proporcji
                decoration: BoxDecoration(
                  color: hasStarted
                      ? Colors.black.withValues(alpha: 0.1) // Wyszarzone
                      : Colors.black.withValues(
                          alpha: 0.25,
                        ), // Wklęsły, ciemny kolor
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      startTimeStr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: hasStarted ? _textHintColor : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      endTimeStr,
                      style: TextStyle(
                        fontSize: 13,
                        color: hasStarted
                            ? Colors.grey.shade700
                            : _textHintColor,
                      ),
                    ),
                  ],
                ),
              ),

              // --- PRAWA STRONA: SZCZEGÓŁY ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tytuł i status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              gymClass.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900, // Gruba czcionka
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isRegistered)
                            Icon(
                              Icons.check_circle,
                              color: _primaryColor, // Neonowy tick
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Opis (krótki)
                      if (gymClass.description.isNotEmpty)
                        Text(
                          gymClass.description,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 12),

                      // Tagi (Chips)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ModernInfoChip(
                            Icons.timer_outlined,
                            "${gymClass.durationMinutes} min",
                            color: _textHintColor,
                          ),
                          ModernInfoChip(
                            Icons.people_outline,
                            isFull ? "Pełne" : "$placesLeft wolnych",
                            color: isFull
                                ? Colors.redAccent
                                : (placesLeft < 3
                                      ? Colors.orangeAccent
                                      : _textHintColor),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Divider(color: _borderColor, height: 1),
                      const SizedBox(height: 16),

                      // Przyciski akcji i instruktor
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Instruktor
                          Expanded(
                            // Używamy Expanded, żeby napis trenera nie wypchnął przycisków
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 16,
                                  color: _textHintColor,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    trainerName,
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Przyciski Trenera lub Klienta
                          if (isTrainer)
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: Colors.blue.shade400,
                                  ),
                                  onPressed: () async {
                                    await context.push(
                                      '/add-edit-class',
                                      extra: gymClass,
                                    );
                                    if (context.mounted) {
                                      context
                                          .read<ScheduleCubit>()
                                          .loadSchedule(selectedDate);
                                    }
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () =>
                                      _deleteClass(context, gymClass.id),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            )
                          else
                            ModernUserButton(
                              context,
                              gymClass,
                              isRegistered,
                              isFull,
                              hasStarted,
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
      ),
    );
  }
}
