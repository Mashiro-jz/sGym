import 'package:agym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:agym/features/auth/presentation/cubit/auth_state.dart';
import 'package:agym/features/schedule/presentation/cubit/trainer_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/trainer_state.dart';
import 'package:agym/features/schedule/presentation/pages/trainer/trainer_class_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/config/injection_container.dart' as di;

class TrainerPage extends StatelessWidget {
  const TrainerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Pobieramy stan autentykacji
    final authState = context.watch<AuthCubit>().state;

    // 1. Zabezpieczenie: Jeśli użytkownik nie jest zalogowany
    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text("Brak dostępu do tego ekranu."),
            ],
          ),
        ),
      );
    }

    // 2. Główny widok dla zalogowanego trenera
    return BlocProvider(
      create: (context) =>
          di.sl<TrainerCubit>()..loadTrainerClasses(authState.user.id),
      child: Scaffold(
        backgroundColor: Colors.grey[100], // Jasne tło dla kontrastu kart
        appBar: AppBar(
          title: const Text("Panel Trenera"),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.blueAccent, // Lub Twój kolor główny
        ),
        body: BlocBuilder<TrainerCubit, TrainerState>(
          builder: (BuildContext context, TrainerState state) {
            if (state is TrainerLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TrainerError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<TrainerCubit>().loadTrainerClasses(
                            authState.user.id,
                          );
                        },
                        child: const Text("Spróbuj ponownie"),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is TrainerLoaded) {
              // Obsługa przypadku, gdy lista jest pusta
              if (state.classes.isEmpty) {
                return _buildEmptyState(context, authState.user.id);
              }

              // Lista zajęć z możliwością odświeżania (Pull-to-refresh)
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<TrainerCubit>().loadTrainerClasses(
                    authState.user.id,
                  );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: state.classes.length,
                  itemBuilder: (context, index) {
                    final gymClass = state.classes[index];
                    return _buildClassCard(gymClass, context);
                  },
                ),
              );
            }

            return const Center(child: Text("Nie można załadować danych"));
          },
        ),
      ),
    );
  }

  // Widget pomocniczy: Karta pojedynczych zajęć
  Widget _buildClassCard(dynamic gymClass, BuildContext context) {
    // Formatowanie daty i godziny (możesz użyć pakietu intl dla lepszego efektu)
    final date = gymClass.startTime;
    final String dayString =
        "${date.day}.${date.month.toString().padLeft(2, '0')}";
    final String timeString =
        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) =>
                    TrainerClassDetailsPage(gymClass: gymClass),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Kolumna z Czasem (Lewa strona)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blueAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        timeString,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayString,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueAccent.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Informacje o zajęciach (Środek)
                Expanded(
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
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Zajęcia grupowe", // Możesz tu dać dynamiczny typ zajęć
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Ikona strzałki (Prawa strona)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pomocniczy: Stan pusty
  Widget _buildEmptyState(BuildContext context, String userId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Brak zaplanowanych zajęć",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                context.read<TrainerCubit>().loadTrainerClasses(userId),
            child: const Text("Odśwież"),
          ),
        ],
      ),
    );
  }
}
