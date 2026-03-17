import 'package:agym/core/widget/modern_class_card.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:agym/features/schedule/presentation/pages/schedule/past_classes_page.dart';
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
        actions: [
          IconButton(
            onPressed: () {
              final currentState = context.read<ScheduleCubit>().state;
              if (currentState is ScheduleLoaded) {
                final pastClasses = currentState.classes.where((gymClass) {
                  return gymClass.startTime.isBefore(DateTime.now());
                }).toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PastClassesPage(gymClasses: pastClasses),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Poczekaj na załadowanie danych..."),
                  ),
                );
              }
            },
            icon: Icon(Icons.calendar_month),
            tooltip: "Zajęcia zakończone",
          ),
        ],
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
            final upComingClasses = state.classes.where((gymClass) {
              return gymClass.startTime.isAfter(DateTime.now());
            }).toList();

            if (upComingClasses.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: upComingClasses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final gymClass = upComingClasses[index];
                final trainerName = state.trainerNames[gymClass.trainerId];
                return ModernClassCard(
                  gymClass: gymClass,
                  trainerName: trainerName ?? "Nieznany trener",
                  isTrainer: isTrainerOrAdmin,
                  currentUserId: currentUserId,
                  selectedDate: _selectedDate,
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
}
