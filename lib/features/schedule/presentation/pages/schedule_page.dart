import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/injection_container.dart' as di;
// Upewnij się, że masz ten enum, lub dostosuj warunek do Stringa
import '../../../../core/enums/user_role.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/gym_class.dart';
import '../cubit/schedule_cubit.dart';
import '../cubit/schedule_state.dart';

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
    );

    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
      });
      if (mounted) {
        context.read<ScheduleCubit>().loadSchedule(newDate);
      }
    }
  }

  // Funkcja usuwania (tylko dla trenera lub managera)
  void _deleteClass(BuildContext context, String classId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Usuń zajęcia"),
        content: const Text("Czy na pewno chcesz usunąć te zajęcia?"),
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
    // Sprawdzamy, kim jest użytkownik (z AuthCubit)
    final authState = context.watch<AuthCubit>().state;
    bool isTrainerOrAdmin = false;
    String currentUserId = '';

    if (authState is Authenticated) {
      // Dostosuj ten warunek do swoich Enumów ról!
      isTrainerOrAdmin =
          authState.user.userRole == UserRole.trainer ||
          authState.user.userRole == UserRole.manager;
      currentUserId = authState.user.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Grafik zajęć", style: TextStyle(fontSize: 18)),
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'pl').format(_selectedDate),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickDate,
          ),
        ],
      ),
      floatingActionButton: isTrainerOrAdmin
          ? FloatingActionButton(
              onPressed: () async {
                await context.push('/add-edit-class');
                if (context.mounted) {
                  context.read<ScheduleCubit>().loadSchedule(_selectedDate);
                }
              },
              child: const Icon(Icons.add),
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
              return const Center(child: Text("Brak zajęć w tym dniu."));
            }

            return ListView.builder(
              itemCount: state.classes.length,
              itemBuilder: (context, index) {
                final gymClass = state.classes[index];
                return _buildClassCard(
                  gymClass,
                  isTrainerOrAdmin,
                  context,
                  currentUserId,
                );
              },
            );
          }
          return const Center(
            child: Text("Wybierz datę, aby zobaczyć grafik."),
          );
        },
      ),
    );
  }

  Widget _buildClassCard(
    GymClass gymClass,
    bool isTrainer,
    BuildContext context,
    String currentUserId,
  ) {
    final timeStr =
        "${gymClass.startTime.hour.toString().padLeft(2, '0')}:${gymClass.startTime.minute.toString().padLeft(2, '0')}";

    // Logika stanu przycisku
    final isRegistered = gymClass.registeredUserIds.contains(currentUserId);
    final isFull = gymClass.registeredUserIds.length >= gymClass.capacity;
    final hasStarted = DateTime.now().isAfter(gymClass.startTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: Text(
            timeStr,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        title: Text(
          gymClass.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Trener ID: ${gymClass.trainerId}"),
            Text(
              "Miejsc: ${gymClass.registeredUserIds.length}/${gymClass.capacity}",
              style: TextStyle(
                color: isFull && !isRegistered ? Colors.red : Colors.black,
                fontWeight: isFull ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        trailing: isTrainer
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      await context.push('/add-edit-class', extra: gymClass);
                      if (context.mounted) {
                        context.read<ScheduleCubit>().loadSchedule(
                          _selectedDate,
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteClass(context, gymClass.id),
                  ),
                ],
              )
            : _buildUserActionButton(
                context,
                gymClass,
                isRegistered,
                isFull,
                hasStarted,
              ),
      ),
    );
  }

  // Pomocnicza funkcja do budowania przycisku dla Usera
  Widget _buildUserActionButton(
    BuildContext context,
    GymClass gymClass,
    bool isRegistered,
    bool isFull,
    bool hasStarted,
  ) {
    if (hasStarted) {
      return const Text("Zakończone", style: TextStyle(color: Colors.grey));
    }

    if (isRegistered) {
      return ElevatedButton(
        onPressed: () {
          context.read<ScheduleCubit>().signOutFromClassActivity(gymClass);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade100,
          foregroundColor: Colors.red,
        ),
        child: const Text("Wypisz się"),
      );
    }

    if (isFull) {
      return const ElevatedButton(onPressed: null, child: Text("Brak miejsc"));
    }

    return ElevatedButton(
      onPressed: () {
        context.read<ScheduleCubit>().signUpForClassActivity(gymClass);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade100,
        foregroundColor: Colors.green.shade800,
      ),
      child: const Text("Zapisz się"),
    );
  }
}
