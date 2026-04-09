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

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812);
  final Color _textHintColor = const Color(0xFF8B9D90);

  @override
  Widget build(BuildContext context) {
    // 1. Pobieramy dane użytkownika z AuthCubita
    final authState = context.watch<AuthCubit>().state;
    String currentUserId = '';

    if (authState is Authenticated) {
      currentUserId = authState.user.id;
    }

    return Scaffold(
      backgroundColor: _bgColor, // Mroczne, butelkowo-zielone tło
      appBar: AppBar(
        title: const Text(
          "Zakończone zajęcia",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: _bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // 2. Jeśli lista jest pusta, pokazujemy ładny komponent zastępczy (Empty State)
      body: gymClasses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 64,
                    color: _textHintColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Brak historii zajęć",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Trener nie ma jeszcze zakończonych treningów.",
                    style: TextStyle(color: _textHintColor, fontSize: 14),
                  ),
                ],
              ),
            )
          // 3. Jeśli są zajęcia, rysujemy listę
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
