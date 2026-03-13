import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:agym/features/schedule/presentation/pages/schedule/schedule_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/config/injection_container.dart' as di;
import '../../../../../core/enums/user_role.dart';
import '../../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../auth/presentation/cubit/auth_state.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ScheduleCubit>()..loadSchedule(DateTime.now()),
      child: const _SchedulePageView(),
    );
  }
}

class _SchedulePageView extends StatefulWidget {
  const _SchedulePageView();

  @override
  State<_SchedulePageView> createState() => _SchedulePageViewState();
}

class _SchedulePageViewState extends State<_SchedulePageView> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pl'),
    );

    if (newDate != null) {
      setState(() => _selectedDate = newDate);
      if (mounted) context.read<ScheduleCubit>().loadSchedule(newDate);
    }
  }

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
    final authState = context.watch<AuthCubit>().state;
    bool isTrainerOrAdmin = false;
    String currentUserId = '';

    if (authState is Authenticated) {
      isTrainerOrAdmin =
          authState.user.userRole == UserRole.trainer ||
          authState.user.userRole == UserRole.manager;
      currentUserId = authState.user.id;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: InkWell(
          onTap: _pickDate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Grafik zajęć", style: TextStyle(fontSize: 16)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM', 'pl').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isTrainerOrAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await context.push('/add-edit-class');
                if (context.mounted) {
                  context.read<ScheduleCubit>().loadSchedule(_selectedDate);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Dodaj zajęcia"),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            )
          : null,
      body: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
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
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScheduleLoaded) {
            if (state.classes.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.classes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final gymClass = state.classes[index];
                final trainerName = state.trainerNames[gymClass.trainerId];
                return _buildModernClassCard(
                  gymClass,
                  trainerName!,
                  isTrainerOrAdmin,
                  context,
                  currentUserId,
                );
              },
            );
          }
          return const Center(child: Text("Wczytywanie..."));
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.weekend,
            size: 80,
            color: Colors.deepPurple.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text(
            "Brak zajęć w tym dniu",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildModernClassCard(
    GymClass gymClass,
    String trainerName,
    bool isTrainer,
    BuildContext context,
    String currentUserId,
  ) {
    final startTimeStr = DateFormat('HH:mm').format(gymClass.startTime);
    final endTimeStr = DateFormat('HH:mm').format(
      gymClass.startTime.add(Duration(minutes: gymClass.durationMinutes)),
    );

    final isRegistered = gymClass.registeredUserIds.contains(currentUserId);
    final isFull = gymClass.registeredUserIds.length >= gymClass.capacity;
    final hasStarted = DateTime.now().isAfter(gymClass.startTime);
    final placesLeft = gymClass.capacity - gymClass.registeredUserIds.length;

    // TODO: USUNĄĆ KLIKANIE NA ZAJĘCIA, KTÓRE JUŻ SIĘ SKOŃCZYŁY
    // TODO: ZAJĘCIA, KTÓRE JUŻ SIĘ SKOŃCZYŁY DAĆ POD JAKIŚ PRZYCISK, ABY NIE BYŁY WIDOCZNE OD RAZU
    return InkWell(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ScheduleDetailsPage(gymClass: gymClass, name: trainerName),
          ),
        ),
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
                          _buildInfoChip(
                            Icons.timer_outlined,
                            "${gymClass.durationMinutes} min",
                          ),
                          _buildInfoChip(
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
                          // Instruktor (Placeholder na razie)
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

                          // Przyciski
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
                                          .loadSchedule(_selectedDate);
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
                            _buildModernUserButton(
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

  Widget _buildInfoChip(
    IconData icon,
    String label, {
    Color color = Colors.grey,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernUserButton(
    BuildContext context,
    GymClass gymClass,
    bool isRegistered,
    bool isFull,
    bool hasStarted,
  ) {
    if (hasStarted) {
      return Text(
        "Zakończone",
        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      );
    }

    if (isRegistered) {
      return OutlinedButton(
        onPressed: () =>
            context.read<ScheduleCubit>().signOutFromClassActivity(gymClass),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          visualDensity: VisualDensity.compact,
        ),
        child: const Text("Wypisz się"),
      );
    }

    if (isFull) {
      return const Text(
        "Brak miejsc",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }

    return FilledButton(
      onPressed: () =>
          context.read<ScheduleCubit>().signUpForClassActivity(gymClass),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        visualDensity: VisualDensity.compact,
      ),
      child: const Text("Zapisz się"),
    );
  }
}
