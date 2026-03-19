import 'package:agym/core/widget/modern_class_card.dart'; // Upewnij się, że ścieżka jest poprawna!
import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../auth/presentation/cubit/auth_state.dart';

class PastClassesPage extends StatelessWidget {
  final List<GymClass> gymClasses;
  final Map<String, String> trainersNames;

  const PastClassesPage({
    super.key,
    required this.gymClasses,
    required this.trainersNames,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Pobieramy dane użytkownika z AuthCubita (jest dostępny wszędzie)
    final authState = context.watch<AuthCubit>().state;
    String currentUserId = '';

    if (authState is Authenticated) {
      currentUserId = authState.user.id;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Zakończone zajęcia"),
        centerTitle: true,
      ),
      // 2. Jeśli lista jest pusta, pokazujemy komunikat
      body: gymClasses.isEmpty
          ? Center(
              child: Text(
                "Brak historii zajęć.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            )
          // 3. Jeśli są zajęcia, rysujemy naszą nową, uniwersalną kartę!
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: gymClasses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final gymClass = gymClasses[index];
                final trainerName = trainersNames[gymClass.trainerId];

                return ModernClassCard(
                  gymClass: gymClass,
                  trainerName: trainerName ?? "Nieznany trener",

                  // Ważne: Wymuszamy 'false', żeby nawet Trener
                  // nie mógł edytować i usuwać zajęć z poziomu historii!
                  isTrainer: false,

                  currentUserId: currentUserId,
                  selectedDate: gymClass.startTime,
                );
              },
            ),
    );
  }
}
