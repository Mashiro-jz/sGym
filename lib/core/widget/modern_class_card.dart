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

  void _deleteClass(BuildContext context, String classId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Usuń zajęcia"),
        content: const Text("Nie będzie można tego cofnąć."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Anuluj"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ScheduleCubit>().deleteClass(classId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Usuń"),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ScheduleDetailsPage(gymClass: gymClass, name: trainerName),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isRegistered
              ? Border.all(color: Colors.green.shade300, width: 2)
              : null,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- LEWA STRONA: CZAS ---
              Container(
                width: 80,
                decoration: BoxDecoration(
                  color: hasStarted
                      ? Colors.grey.shade200
                      : Colors.deepPurple.shade50,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      startTimeStr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: hasStarted ? Colors.grey : Colors.deepPurple,
                      ),
                    ),
                    Text(
                      endTimeStr,
                      style: TextStyle(
                        fontSize: 14,
                        color: hasStarted
                            ? Colors.grey
                            : Colors.deepPurple.shade300,
                      ),
                    ),
                  ],
                ),
              ),

              // --- PRAWA STRONA: SZCZEGÓŁY ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
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
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isRegistered)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Opis
                      if (gymClass.description.isNotEmpty)
                        Text(
                          gymClass.description,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 10),

                      // Tagi (Chips)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          ModernInfoChip(
                            // Zaktualizowana nazwa Twojej klasy Chipa
                            Icons.timer_outlined,
                            "${gymClass.durationMinutes} min",
                          ),
                          ModernInfoChip(
                            Icons.people_outline,
                            isFull ? "Pełne" : "$placesLeft wolnych",
                            color: isFull
                                ? Colors.red
                                : (placesLeft < 3
                                      ? Colors.orange
                                      : Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(),

                      // Przyciski akcji
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Instruktor
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                trainerName,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          // Przyciski Trenera lub Klienta
                          if (isTrainer)
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.blue,
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
                                    color: Colors.red,
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
