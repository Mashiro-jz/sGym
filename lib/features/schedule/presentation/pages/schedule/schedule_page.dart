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
  List<String> _selectedFilters = [];
  final List<String> _allAvailableFilters = ClassLevel.values
      .map((e) => e.displayName)
      .toList();

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812);
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _borderColor = const Color(0xFF2A3D2D);
  final Color _textHintColor = const Color(0xFF8B9D90);

  void _openFilterDelegate() async {
    // Uwaga: Komponent FilterListDialog ma własne stylowanie. Jeśli będzie za jasny,
    // warto napisać własny (np. BottomSheet) w przyszłości, ale na razie go zostawiamy.
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
      builder: (context, child) {
        // Kolorowanie kalendarza pod styl Dark Fitness
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _primaryColor, // Kolor wybranej daty
              onPrimary: Colors.black, // Kolor tekstu na wybranej dacie
              surface: _surfaceColor, // Tło kalendarza
              onSurface: Colors.white, // Tekst dat w kalendarzu
            ),
          ),
          child: child!,
        );
      },
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
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        title: InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Grafik zajęć",
                  style: TextStyle(fontSize: 14, color: _textHintColor),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM', 'pl').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: _primaryColor),
                  ],
                ),
              ],
            ),
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
                  SnackBar(
                    content: const Text(
                      "Poczekaj na załadowanie danych...",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.orangeAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: Icon(Icons.history, color: _textHintColor),
            tooltip: "Zajęcia zakończone",
          ),
          IconButton(
            onPressed: () => _openFilterDelegate(),
            icon: Stack(
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  color: _selectedFilters.isNotEmpty
                      ? _primaryColor
                      : _textHintColor,
                ),
                if (_selectedFilters.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
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
          const SizedBox(width: 8),
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
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                "Dodaj zajęcia",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
              backgroundColor: _primaryColor, // Neonowy guzik dla Trenera!
              elevation: 8,
            )
          : null,
      body: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                backgroundColor: _primaryColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is ScheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return Center(
              child: CircularProgressIndicator(color: _primaryColor),
            );
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: _textHintColor,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Brak zajęć",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Nie znaleziono wyników dla tych filtrów.",
                            style: TextStyle(color: _textHintColor),
                          ),
                        ],
                      ),
                    )
                  : _buildEmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ), // Szersze marginesy jak na Mockupie
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

          return Center(
            child: Text(
              "Wystąpił błąd wczytywania.",
              style: TextStyle(color: _textHintColor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.weekend_outlined, size: 80, color: _borderColor),
          const SizedBox(height: 20),
          const Text(
            "Brak zajęć w tym dniu",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Wybierz inną datę z kalendarza.",
            style: TextStyle(color: _textHintColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
