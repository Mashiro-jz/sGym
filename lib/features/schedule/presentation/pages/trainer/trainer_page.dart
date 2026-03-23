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
        backgroundColor: Colors.grey.shade50, // Jasne, nowoczesne tło
        appBar: AppBar(
          title: const Text(
            "Panel Trenera",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: BlocBuilder<TrainerCubit, TrainerState>(
          builder: (BuildContext context, TrainerState state) {
            if (state is TrainerLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              );
            }

            if (state is TrainerError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
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
                color: Colors.deepPurple,
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
    // Formatowanie daty i godziny
    final date = gymClass.startTime;
    final String dayString =
        "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}";
    final String timeString =
        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Mocniejsze zaokrąglenie
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.03,
            ), // Bardzo delikatny cień
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
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
                    color: Colors.deepPurple.shade50, // Fioletowe tło pigułki
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        timeString,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayString,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.deepPurple.shade300,
                          fontWeight: FontWeight.w600,
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
                          Icon(
                            Icons.fitness_center,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            gymClass.category, // Dynamiczna kategoria z bazy
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
                  color: Colors.grey[300],
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
            color: Colors.deepPurple.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 24),
          Text(
            "Brak zaplanowanych zajęć",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () =>
                context.read<TrainerCubit>().loadTrainerClasses(userId),
            icon: const Icon(Icons.refresh, color: Colors.deepPurple),
            label: const Text(
              "Odśwież",
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
