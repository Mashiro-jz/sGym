import 'package:agym/core/widget/modern_class_card.dart';
import 'package:agym/features/schedule/domain/enums/class_level.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:agym/features/schedule/presentation/pages/schedule/past_classes_page.dart';
import 'package:filter_list/filter_list.dart';
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
  List<String> _selectedFilters = []; // Lista przechowująca zaznaczone filtry
  final List<String> _allAvailableFilters = ClassLevel.values
      .map((e) => e.displayName)
      .toList();

  void _openFilterDelegate() async {
    await FilterListDialog.display<String>(
      context,
      listData: _allAvailableFilters,
      selectedListData: _selectedFilters,
      headlineText: "Filtruj poziomy",
      applyButtonText: "Zatwierdź",
      choiceChipLabel: (filter) => filter,

      validateSelectedItem: (list, item) {
        return list != null && list.contains(item);
      },

      onItemSearch: (filter, query) {
        return filter.toLowerCase().contains(query.toLowerCase());
      },

      onApplyButtonClick: (list) {
        setState(() {
          _selectedFilters = list != null ? List.from(list) : [];
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        });
      },
    );
  }

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
                    builder: (context) => PastClassesPage(
                      gymClasses: pastClasses,
                      trainersNames: currentState.trainerNames,
                    ),
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
            icon: const Icon(Icons.history),
            tooltip: "Zajęcia zakończone",
          ),
          IconButton(
            onPressed: () => _openFilterDelegate(),
            icon: Stack(
              children: [
                // TODO: Przetestuj filtrowanie oraz niech Ci chat wytłumaczy wszystko oraz nauczy korzystać z dokumentacji i gdzie ją znaleźć
                const Icon(Icons.filter_alt_outlined),
                // Mała czerwona kropka, jeśli jakiś filtr jest aktywny!
                if (_selectedFilters.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: "Filtruj zajęcia",
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
            var upComingClasses = state.classes.where((gymClass) {
              return gymClass.startTime.isAfter(DateTime.now());
            }).toList();

            // Aplikujemy wybrane filtry
            if (_selectedFilters.isNotEmpty) {
              upComingClasses = upComingClasses.where((gymClass) {
                final hasCategory = _selectedFilters.contains(
                  gymClass.category,
                );
                final hasLevel = _selectedFilters.contains(
                  gymClass.classLevel.displayName,
                );
                return hasCategory || hasLevel;
              }).toList();
            }

            if (upComingClasses.isEmpty) {
              return _selectedFilters.isNotEmpty
                  ? const Center(
                      child: Text("Brak zajęć dla podanych filtrów."),
                    )
                  : _buildEmptyState();
            }

            // TUTEJ BYŁ BŁĄD! Zwracałeś text "Wczytywanie..." zamiast listy kafelków!
            // Przywrócona funkcja renderowania:
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

          return const Center(child: Text("Wystąpił błąd wczytywania."));
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
